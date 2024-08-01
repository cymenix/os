{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules;
  user = cfg.users.user;
  isDesktop = cfg.display.gui != "headless";
  vmip = "192.168.122.1";
  vm = "win11";
  vnc = 5900;
  host = "192.168.178.30";
  ovmf =
    (pkgs.OVMFFull.override {
      secureBoot = true;
      tpmSupport = true;
    })
    .fd;
  iptables = pkgs.writeShellScriptBin "iptables.sh" ''
    GUEST_IP="${vmip}"
    GUEST_PORT="${builtins.toString vnc}"
    HOST_PORT="${builtins.toString vnc}"
    if [ "$1" = "${vm}" ]; then
      iptables -A FORWARD -s ${host}/24 -d 192.168.122.0/24 -o virbr0 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
      if [ "$2" = "stopped" ] || [ "$2" = "reconnect" ]; then
       iptables -D FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
       iptables -t nat -D PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
      fi
      if [ "$2" = "start" ] || [ "$2" = "reconnect" ]; then
       iptables -I FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
       iptables -t nat -I PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
      fi
    fi
  '';
  kvm-conf = pkgs.writeShellScriptBin "kvm.conf" ''
    VIRSH_GPU_VIDEO=pci_0000_03_00_0
    VIRSH_GPU_AUDIO=pci_0000_03_00_1
  '';
  qemu = pkgs.writeShellScriptBin "qemu" ''
    set -e
    GUEST_NAME="$1"
    HOOK_NAME="$2"
    STATE_NAME="$3"
    MISC="''${@:4}"
    BASEDIR="$(dirname $0)"
    HOOKPATH="$BASEDIR/qemu.d/$GUEST_NAME/$HOOK_NAME/$STATE_NAME"
    if [ -f "$HOOKPATH" ] && [ -s "$HOOKPATH"] && [ -x "$HOOKPATH" ]; then
        eval \"$HOOKPATH\" "$@"
    elif [ -d "$HOOKPATH" ]; then
        while read file; do
            if [ ! -z "$file" ]; then
              eval \"$file\" "$@"
            fi
        done <<< "$(find -L "$HOOKPATH" -maxdepth 1 -type f -executable -print;)"
    fi
  '';
  start = pkgs.writeShellScriptBin "start.sh" ''
    unbind_module() {
      module=$1
      echo "Unbinding module: $module"
      sudo rmmod $module
      if [ $? -ne 0 ]; then
        echo "Failed to unbind $module. Exiting."
        exit 1
      fi
    }
    modules=(
      drm_display_helper
      drm_buddy
      drm_suballoc_helper
      gpu_sched
      drm_exec
      ttm
      drm_ttm_helper
      i2c_algo_bit
      amdxcp
      backlight
      video
      amdgpu
    )
    logfile=/home/${user}/startlogfile
    exec 19>$logfile
    BASH_XTRACEFD=19
    set -x
    source ${kvm-conf}/bin/kvm.conf
    systemctl stop display-manager.service
    systemctl isolate multi-user.target
    while systemctl is-active --quiet "display-manager.service"; do
      sleep 1
    done
    echo 0 > /sys/class/vtconsole/vtcon0/bind
    echo 0 > /sys/class/vtconsole/vtcon1/bind
    sleep 1
    for module in "''${modules[@]}"; do
      unbind_module $module
    done
    modprobe -r amdgpu
    sleep 1
    virsh nodedev-detach $VIRSH_GPU_VIDEO
    virsh nodedev-detach $VIRSH_GPU_AUDIO
    sleep 1
    modprobe vfio-pci
  '';
  stop = pkgs.writeShellScriptBin "stop.sh" ''
    exec 19>/home/${user}/startlogfile
    BASH_XTRACEFD=19
    set -x
    source ${kvm-conf}/bin/kvm.conf
    virsh nodedev-reattach $VIRSH_GPU_VIDEO
    virsh nodedev-reattach $VIRSH_GPU_AUDIO
    modprobe -r vfio-pci
    modprobe amdgpu
    echo 1 > /sys/class/vtconsole/vtcon0/bind
    echo 1 > /sys/class/vtconsole/vtcon1/bind
    systemctl start display-manager.service
  '';
in
  with lib; {
    imports = [
      ./docker
      ./virt-manager
    ];
    options = {
      modules = {
        virtualisation = {
          enable = mkEnableOption "Enable virtualisation" // {default = false;};
        };
      };
    };
    config = mkIf (cfg.enable && cfg.virtualisation.enable) {
      systemd = {
        services = {
          libvirtd = {
            path = [
              (pkgs.buildEnv {
                name = "qemu-hook-env";
                paths = with pkgs; [bash libvirt kmod systemd ripgrep sd];
              })
            ];
            preStart = ''
              mkdir -p /var/lib/libvirt/hooks/qemu.d/${vm}/prepare/begin
              mkdir -p /var/lib/libvirt/hooks/qemu.d/${vm}/release/end
              ln -sf ${qemu}/bin/qemu /var/lib/libvirt/hooks/qemu
              ln -sf ${start}/bin/start.sh /var/lib/libvirt/hooks/qemu.d/${vm}/prepare/begin/start.sh
              ln -sf ${stop}/bin/stop.sh /var/lib/libvirt/hooks/qemu.d/${vm}/release/end/stop.sh
            '';
          };
        };
        tmpfiles = {
          rules = let
            firmware = pkgs.runCommandLocal "qemu-firmware" {} ''
              mkdir $out
              cp ${pkgs.qemu}/share/qemu/firmware/*.json $out
            '';
          in ["L+ /var/lib/qemu/firmware - - - - ${firmware}"];
        };
      };
      environment = {
        systemPackages = with pkgs; [
          virt-manager
          virt-viewer
          spice
          spice-gtk
          spice-protocol
          libguestfs
          win-virtio
          win-spice
        ];
      };
      boot = {
        kernelModules = [
          "vfio"
          "vfio_pci"
          "vfio_virqfd"
          "vfio_iommu_type1"
        ];
        kernelParams = [
          "intel_iommu=on"
          "iommu=pt"
        ];
      };
      virtualisation = {
        libvirtd = {
          enable = cfg.virtualisation.enable;
          onBoot = "ignore";
          onShutdown = "shutdown";
          allowedBridges = ["virbr0"];
          qemu = {
            package = pkgs.qemu_kvm;
            runAsRoot = true;
            ovmf = {
              enable = cfg.virtualisation.enable;
              packages = [ovmf];
            };
            swtpm = {
              enable = cfg.virtualisation.enable;
            };
          };
          hooks = {
            qemu = {
              iptables = "${iptables}/bin/iptables.sh";
            };
          };
        };
        spiceUSBRedirection = {
          enable = cfg.virtualisation.enable;
        };
      };
      services = {
        spice-vdagentd = {
          enable = cfg.virtualisation.enable;
        };
        spice-webdavd = {
          enable = cfg.virtualisation.enable;
        };
      };
      networking = {
        firewall = {
          allowedTCPPorts = [vnc];
        };
        nat = {
          enable = true;
          internalInterfaces = ["wlp4s0"];
          externalInterface = "virbr0";
          forwardPorts = [
            {
              destination = "${vmip}:${builtins.toString vnc}";
              proto = "tcp";
              sourcePort = vnc;
            }
          ];
        };
      };
      users = {
        users = {
          ${user} = {
            extraGroups = ["libvirtd" "kvm" "input"];
          };
        };
      };
      home-manager = mkIf (cfg.home-manager.enable && isDesktop) {
        users = {
          ${user} = {
            dconf = {
              settings = {
                "org/virt-manager/virt-manager/connections" = {
                  autoconnect = ["qemu:///system"];
                  uris = ["qemu:///system"];
                };
              };
            };
          };
        };
      };
    };
  }
