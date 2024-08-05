{
  lib,
  config,
  ...
}: let
  cfg = config.modules.gaming;
in
  with lib; {
    imports = [
      ./wc3
    ];
    options = {
      modules = {
        gaming = {
          games = {
            enable = mkEnableOption "Enable games" // {default = cfg.enable;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.games.enable) {
      programs = {
        games = {
          enable = cfg.games.enable;
        };
      };
    };
  }
