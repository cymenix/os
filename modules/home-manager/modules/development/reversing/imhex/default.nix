{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.development.reversing;
in
  with lib; {
    options = {
      modules = {
        development = {
          reversing = {
            imhex = {
              enable = mkEnableOption "Enable imhex" // {default = cfg.enable;};
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.imhex.enable) {
      home = {
        packages = with pkgs; [imhex];
      };
    };
  }
