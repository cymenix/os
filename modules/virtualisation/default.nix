{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules;
  user = cfg.users.user;
  isDesktop = cfg.display.gui != "headless";
  ovmf =
    (pkgs.OVMFFull.override {
      secureBoot = true;
      tpmSupport = true;
    })
    .fd;
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
    logfile=/home/${user}/startlogfile
    exec 19>$logfile
    BASH_XTRACEFD=19
    set -x
    source ${kvm-conf}/bin/kvm.conf
    echo "Tuning CPU settings" >> $logfile
    systemctl set-property --runtime -- user.slice AllowedCPUs=0
    systemctl set-property --runtime -- system.slice AllowedCPUs=0
    systemctl set-property --runtime -- init.scope AllowedCPUs=0
    echo "Stopping display manager"  >> $logfile
    systemctl stop display-manager.service
    sleep 1
    echo "Unbinfing Efi framebuffer" >> $logfile
    echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
    sleep 5
    echo "Tweaking vtconsole" >> $logfile
    echo 0 > /sys/class/vtconsole/vtcon0/bind
    echo 0 > /sys/class/vtconsole/vtcon1/bind
    echo "Unloading amdgpu driver" >> $logfile
    modprobe -r amdgpu
    sleep 1
    echo "Detaching PCI devices" >> $logfile
    virsh nodedev-detach $VIRSH_GPU_VIDEO
    virsh nodedev-detach $VIRSH_GPU_AUDIO
    echo "Loading VFIO PCI driver" >> $logfile
    modprobe vfio-pci
  '';
  stop = pkgs.writeShellScriptBin "stop.sh" ''
    exec 19>/home/${user}/startlogfile
    BASH_XTRACEFD=19
    set -x
    source ${kvm-conf}/bin/kvm.conf
    systemctl set-property --runtime -- user.slice AllowedCPUs=0
    systemctl set-property --runtime -- system.slice AllowedCPUs=0
    systemctl set-property --runtime -- init.scope AllowedCPUs=0
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
              mkdir -p /var/lib/libvirt/hooks
              mkdir -p /var/lib/libvirt/hooks/qemu.d/win11/prepare/begin
              mkdir -p /var/lib/libvirt/hooks/qemu.d/win11/release/end
              mkdir -p /var/lib/libvirt/vgabios

              ln -sf ${kvm-conf}/bin/kvm.conf /var/lib/libvirt/hooks
              ln -sf ${qemu}/bin/qemu /var/lib/libvirt/hooks/qemu
              ln -sf ${start}/bin/start.sh /var/lib/libvirt/hooks/qemu.d/win11/prepare/begin/start.sh
              ln -sf ${stop}/bin/stop.sh /var/lib/libvirt/hooks/qemu.d/win11/release/end/stop.sh
              ln -sf ${./vbios/vbios.rom} /var/lib/libvirt/vgabios/patched.rom
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
          "hugepagesz=1G"
          "hugepages=24"
        ];
      };
      virtualisation = {
        libvirtd = {
          enable = cfg.virtualisation.enable;
          onBoot = "ignore";
          onShutdown = "shutdown";
          allowedBridges = [
            "nm-bridge"
            "virbr0"
          ];
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
        qemuGuest = {
          enable = cfg.virtualisation.enable;
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
