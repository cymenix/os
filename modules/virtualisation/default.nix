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
  pcids = ["1002:744c" "1002:ab30"];
  kvm-conf = pkgs.writeText "kvm.conf" ''
    VIRSH_GPU_VIDEO=pci_0000_01_00_0
    VIRSH_GPU_AUDIO=pci_0000_01_00_1
  '';
  qemu = pkgs.writeShellScriptBin "qemu" ''
    #
    # Author: Sebastiaan Meijer (sebastiaan@passthroughpo.st)
    #
    # Copy this file to /etc/libvirt/hooks, make sure it's called "qemu".
    # After this file is installed, restart libvirt.
    # From now on, you can easily add per-guest qemu hooks.
    # Add your hooks in /etc/libvirt/hooks/qemu.d/vm_name/hook_name/state_name.
    # For a list of available hooks, please refer to https://www.libvirt.org/hooks.html
    #

    GUEST_NAME="$1"
    HOOK_NAME="$2"
    STATE_NAME="$3"
    MISC="''${@:4}"

    BASEDIR="$(dirname $0)"

    HOOKPATH="$BASEDIR/qemu.d/$GUEST_NAME/$HOOK_NAME/$STATE_NAME"

    set -e # If a script exits with an error, we should as well.

    # check if it's a non-empty executable file
    if [ -f "$HOOKPATH" ] && [ -s "$HOOKPATH"] && [ -x "$HOOKPATH" ]; then
        eval \"$HOOKPATH\" "$@"
    elif [ -d "$HOOKPATH" ]; then
        while read file; do
            # check for null string
            if [ ! -z "$file" ]; then
              eval \"$file\" "$@"
            fi
        done <<< "$(find -L "$HOOKPATH" -maxdepth 1 -type f -executable -print;)"
    fi
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

              ln -sf ${kvm-conf} /var/lib/libvirt/hooks/kvm.conf
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
            runAsRoot = false;
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
