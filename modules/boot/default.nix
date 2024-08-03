{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules;
  isDesktop = config.modules.display.gui != "headless";
in
  with lib; {
    imports = [
      ./secureboot
      ./themes
    ];
    options = {
      modules = {
        boot = {
          enable = mkEnableOption "Enable bootloader" // {default = cfg.enable && isDesktop;};
        };
      };
    };
    config = mkIf (cfg.enable && cfg.boot.enable && isDesktop) {
      boot = {
        kernelPackages = lib.mkDefault pkgs.linuxPackages_xanmod_latest;
        supportedFilesystems = ["ntfs"];
        loader = {
          systemd-boot = {
            enable = true;
          };
          grub = {
            enable = lib.mkForce false;
            device = "nodev";
            efiSupport = true;
            useOSProber = true;
          };
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
          };
        };
        extraModulePackages = with config.boot.kernelPackages; [
          v4l2loopback.out
        ];
        kernelModules = [
          "v4l2loopback"
        ];
        extraModprobeConfig = ''
          options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
        '';
      };
    };
  }
