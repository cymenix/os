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
      ./nm
      ./torrent
    ];
    options = {
      modules = {
        networking = {
          enable = mkEnableOption "Enable networking" // {default = osCfg.networking.enable && cfg.enable;};
        };
      };
    };
  }
