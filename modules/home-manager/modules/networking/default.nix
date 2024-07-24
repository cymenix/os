{
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.modules;
  osCfg = osConfig.modules;
in
  with lib; {
    imports = [
      ./bluetooth
      ./irc
      ./nm
      ./proxy
    ];
    options = {
      modules = {
        networking = {
          enable = mkEnableOption "Enable networking" // {default = osCfg.networking.enable && cfg.enable;};
        };
      };
    };
  }
