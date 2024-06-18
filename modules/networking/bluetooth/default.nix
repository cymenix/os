{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.networking;
  bluez = "${import ./bluez {inherit pkgs lib;}}";
in
  with lib; {
    options = {
      modules = {
        networking = {
          bluetooth = {
            enable = mkEnableOption "Enable bluetooth" // {default = cfg.enable;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.bluetooth.enable) {
      environment = {
        systemPackages = with pkgs; [
          python311Packages.ds4drv
        ];
      };
      boot = {
        kernelParams = [
          "btusb.enable_autosuspend=n"
        ];
      };
      hardware = {
        bluetooth = {
          enable = cfg.bluetooth.enable;
          powerOnBoot = true;
          package = bluez;
          input = {
            General = {
              UserspaceHID = true;
            };
          };
          settings = {
            General = {
              ControllerMode = "bredr";
              FastConnectable = true;
              Enable = "Source,Sink,Media,Socket";
            };
          };
        };
      };
      services = {
        blueman = {
          enable = cfg.bluetooth.enable;
        };
      };
    };
  }
