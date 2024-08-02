{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules;
  user = cfg.users.user;
  isDesktop = cfg.display.gui != "headless";
  vm = "win11";
  interface = "wlp4s0";
  vmip = "192.168.122.1";
  host = "192.168.178.30";
  vnc = 5900;
  ovmf =
    (pkgs.OVMFFull.override {
      secureBoot = true;
      tpmSupport = true;
    })
    .fd;
  pcis = ["pci_0000_03_00_0" "pci_0000_03_00_1"];
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
    if [ "$1" = "${vm}" ] && [ "$2" = "prepare" ] && [ "$3" = "begin" ]; then
      ${pkgs.bash}/bin/set -x
      echo "Starting ${vm}" > /home/${user}/win11.log
      ${pkgs.systemd}/bin/systemctl stop display-manager.service
      ${pkgs.systemd}/bin/systemctl isolate multi-user.target
      ${pkgs.systemd}/bin/systemctl stop lactd.service
      echo 0 > /sys/class/vtconsole/vtcon0/bind
      echo 0 > /sys/class/vtconsole/vtcon1/bind
      ${pkgs.kmod}/bin/modprobe -r amdgpu
      sleep 1
      ${builtins.concatStringsSep "\n" (map (pci: "${pkgs.libvirt}/bin/virsh nodedev-detach ${pci}") pcis)}
      sleep 1
      ${pkgs.kmod}/bin/modprobe vfio-pci
    fi
  '';
  stop = pkgs.writeShellScriptBin "stop.sh" ''
    if [ "$1" = "${vm}" ] && [ "$2" = "release" ] && [ "$3" = "end" ]; then
      ${pkgs.bash}/bin/set -x
      echo "Stopping ${vm}" >> /home/${user}/win11.log
      ${builtins.concatStringsSep "\n" (map (pci: "${pkgs.libvirt}/bin/virsh nodedev-reattach ${pci}") pcis)}
      ${pkgs.kmod}/bin/modprobe -r vfio-pci
      ${pkgs.kmod}/bin/modprobe amdgpu
      echo 1 > /sys/class/vtconsole/vtcon0/bind
      echo 1 > /sys/class/vtconsole/vtcon1/bind
      ${pkgs.systemd}/bin/systemctl start display-manager.service
      ${pkgs.systemd}/bin/systemctl start lactd.service
    fi
  '';
in {
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
    boot = {
      kernelParams = ["intel_iommu=on" "iommu=pt"];
      kernelModules = ["vfio" "vfio_pci" "vfio_virqfd" "vfio_iommu_type1"];
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
    systemd = {
      services = {
        libvirtd = {
          preStart = ''
            ln -sf ${qemu}/bin/qemu /var/lib/libvirt/hooks/qemu
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
    virtualisation = {
      libvirtd = {
        inherit (cfg.virtualisation) enable;
        onBoot = "ignore";
        onShutdown = "shutdown";
        allowedBridges = ["virbr0"];
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          ovmf = {
            inherit (cfg.virtualisation) enable;
            packages = [ovmf];
          };
          swtpm = {
            inherit (cfg.virtualisation) enable;
          };
        };
        hooks = {
          qemu = {
            iptables = "${iptables}/bin/iptables.sh";
            start = "${start}/bin/start.sh";
            stop = "${stop}/bin/stop.sh";
          };
        };
      };
      spiceUSBRedirection = {
        inherit (cfg.virtualisation) enable;
      };
    };
    services = {
      spice-vdagentd = {
        inherit (cfg.virtualisation) enable;
      };
      spice-webdavd = {
        inherit (cfg.virtualisation) enable;
      };
      qemuGuest = {
        inherit (cfg.virtualisation) enable;
      };
    };
    networking = {
      firewall = {
        allowedTCPPorts = [vnc];
      };
      nat = {
        inherit (cfg.virtualisation) enable;
        internalInterfaces = [interface];
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
