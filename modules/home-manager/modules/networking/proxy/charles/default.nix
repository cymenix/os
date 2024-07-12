{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.networking.proxy;
in
  with lib; {
    options = {
      modules = {
        networking = {
          proxy = {
            charles = {
              enable = mkEnableOption "Enable charles web debugging proxy" // {default = cfg.enable;};
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.charles.enable) {
      home = {
        packages = with pkgs; [
          charles
        ];
      };
    };
  }
