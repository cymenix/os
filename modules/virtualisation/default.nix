{
  inputs,
  system,
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules;
  user = cfg.users.user;
  isDesktop = cfg.display.gui != "headless";
in {
  imports = [
    ./docker
    ./virt-manager
    inputs.vfio.nixosModules.${system}.default
  ];
  options = {
    modules = {
      virtualisation = {
        enable = mkEnableOption "Enable virtualisation" // {default = false;};
      };
    };
  };
  config = mkIf (cfg.enable && cfg.virtualisation.enable) {
    virtualisation = {
      vfio = {
        inherit user;
        inherit (cfg.virtualisation) enable;
        passthrough = true;
        vm = "win11";
        cpu = "intel";
        gpu = "amd";
        pcis = ["pci_0000_03_00_0" "pci_0000_03_00_1"];
        vnc = {
          inherit (cfg.virtualisation) enable;
          interface = "wlp4s0";
          host = {
            ip = "192.168.178.30";
          };
        };
      };
      libvirtd = {
        inherit (cfg.virtualisation) enable;
        qemu = {
          package = pkgs.qemu_kvm;
          vhostUserPackages = [pkgs.virtiofsd];
          swtpm = {
            inherit (cfg.virtualisation) enable;
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
