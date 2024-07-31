{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules;
  user = cfg.users.user;
  isDesktop = cfg.display.gui != "headless";
  # special anti-detection emulator
  qemu-anti-detection =
    (pkgs.qemu_kvm.override {
      hostCpuOnly = true;
    })
    .overrideAttrs (finalAttrs: previousAttrs: {
      # ref: https://github.com/zhaodice/qemu-anti-detection
      src = pkgs.fetchurl {
        url = "https://download.qemu.org/qemu-${finalAttrs.version}.tar.xz";
        hash = "sha256-vwDS+hIBDfiwrekzcd71jmMssypr/cX1oP+Oah+xvzI=";
      };
      patches =
        (previousAttrs.patches or [])
        ++ [
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/zhaodice/qemu-anti-detection/main/qemu-8.2.0.patch";
            sha256 = "0apkgnw4khlskq9kckx84np1qd6v3yblddyhf3hf1f1apxwpy8fc";
          })
        ];
      postFixup =
        (previousAttrs.postFixup or "")
        + "\n"
        + ''
          for i in $(find $out/bin -type f -executable); do
            mv $i "$i-anti-detection"
          done
        '';
      version = "8.2.0";
      pname = "qemu-anti-detection";
    });
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
          qemu_kvm
          qemu-anti-detection
        ];
      };
      virtualisation = {
        libvirtd = {
          enable = cfg.virtualisation.enable;
          onBoot = "ignore";
          onShutdown = "suspend";
          allowedBridges = [
            "nm-bridge"
            "virbr0"
          ];
          qemu = {
            package = qemu-anti-detection;
            runAsRoot = false;
            ovmf = {
              enable = cfg.virtualisation.enable;
              packages = [
                (pkgs.OVMF.override {
                  secureBoot = true;
                  tpmSupport = true;
                })
                .fd
              ];
            };
            swtpm = {
              enable = cfg.virtualisation.enable;
            };
            verbatimConfig = ''
              bridge_helper = "${qemu-anti-detection}/libexec/qemu-bridge-helper"
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
