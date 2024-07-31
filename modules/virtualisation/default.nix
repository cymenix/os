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
              packages = [
                ovmf
              ];
            };
            swtpm = {
              enable = cfg.virtualisation.enable;
            };
            verbatimConfig = ''
              nvram = ["${ovmf}/FV/OVMF_CODE.fd:${ovmf}/FV/OVMF_VARS.fd"]
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

