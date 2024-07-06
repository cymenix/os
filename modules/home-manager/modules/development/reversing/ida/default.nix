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
            ida = {
              enable = mkEnableOption "Enable IDA free" // {default = cfg.enable;};
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.ida.enable) {
      home = {
        packages = with pkgs; [ida-free];
      };
    };
  }
