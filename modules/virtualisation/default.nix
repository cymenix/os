{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules;
  user = cfg.users.user;
  isDesktop = cfg.display.gui != "headless";
  # ovmf =
  #   (pkgs.OVMFFull.override {
  #     secureBoot = true;
  #     tpmSupport = true;
  #   })
  #   .fd;
  # special anti-detection emulator
  # qemu-anti-detection =
  #   (pkgs.qemu.override {
  #     hostCpuOnly = true;
  #   })
  #   .overrideAttrs (finalAttrs: previousAttrs: {
  #     # ref: https://github.com/zhaodice/qemu-anti-detection
  #     postPatch = let
  #       patch = pkgs.fetchpatch {
  #         url = "https://github.com/user-attachments/files/16114500/qemu-9.0.1-anti-detection.patch";
  #         sha256 = "sha256-HZo6DrscVCSwIhCMp1jsZqMniH73Fu8z/Outg7bHf+0=";
  #       };
  #     in
  #       (previousAttrs.postPatch or "")
  #       + "\n"
  #       + ''
  #         patch -p1 < "${patch}" || true
  #       '';
  #     postFixup =
  #       (previousAttrs.postFixup or "")
  #       + "\n"
  #       + ''
  #         for i in $(find $out/bin -type f -executable); do
  #           mv $i "$i-anti-detection"
  #         done
  #       '';
  #     version = "9.0.2";
  #     pname = "qemu-anti-detection";
  #   });
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
        tmpfiles = {
          rules = let
            firmware = pkgs.runCommandLocal "qemu-firmware" {} ''
              mkdir $out
              cp ${pkgs.qemu}/share/qemu/firmware/*.json $out
              substituteInPlace $out/*.json --replace ${pkgs.qemu} /run/current-system/sw
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
          win-virtio
          win-spice
          gnome.adwaita-icon-theme
          # qemu_kvm
          # ovmf
          # (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
          #   qemu-system-x86_64 \
          #     -bios ${ovmf}/FV/OVMF.fd \
          #     "$@"
          # '')
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
            # runAsRoot = false;
            ovmf = {
              enable = cfg.virtualisation.enable;
              # packages = [
              #   ovmf
              # ];
            };
            swtpm = {
              enable = cfg.virtualisation.enable;
            };
            verbatimConfig = ''
              bridge_helper = "${pkgs.qemu}/libexec/qemu-bridge-helper"
            '';
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
            extraGroups = ["libvirtd" "kvm"];
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
# {
#   pkgs,
#   config,
#   lib,
#   ...
# }: let
#   cfg = config.modules;
#   user = cfg.users.user;
#   isDesktop = cfg.display.gui != "headless";
# in
#   with lib; {
#     imports = [
#       ./docker
#       ./virt-manager
#     ];
#     options = {
#       modules = {
#         virtualisation = {
#           enable = mkEnableOption "Enable virtualisation" // {default = isDesktop;};
#         };
#       };
#     };
#     config = mkIf (cfg.enable && cfg.virtualisation.enable) {
#       virtualisation = {
#         libvirtd = {
#           enable = cfg.virtualisation.enable;
#           onBoot = "ignore";
#           qemu = {
#             ovmf = {
#               enable = cfg.virtualisation.enable;
#             };
#             swtpm = {
#               enable = cfg.virtualisation.enable;
#             };
#             verbatimConfig = ''
#               bridge_helper = "${pkgs.qemu}/libexec/qemu-bridge-helper"
#             '';
#           };
#         };
#         spiceUSBRedirection = {
#           enable = cfg.virtualisation.enable;
#         };
#       };
#       users = {
#         users = {
#           ${user} = {
#             extraGroups = ["libvirtd" "kvm"];
#           };
#         };
#       };
#       home-manager = mkIf (cfg.home-manager.enable && isDesktop) {
#         users = {
#           ${user} = {
#             dconf = {
#               settings = {
#                 "org/virt-manager/virt-manager/connections" = {
#                   autoconnect = ["qemu:///system"];
#                   uris = ["qemu:///system"];
#                 };
#               };
#             };
#           };
#         };
#       };
#     };
#   }

