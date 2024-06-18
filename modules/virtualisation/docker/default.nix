{
  config,
  lib,
  ...
}: let
  cfg = config.modules.virtualisation;
in
  with lib; {
    options = {
      modules = {
        virtualisation = {
          docker = {
            enable = mkEnableOption "Enable docker" // {default = cfg.enable;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.docker.enable) {
      virtualisation = {
        docker = {
          enable = cfg.docker.enable;
        };
      };
      users = {
        users = {
          ${config.modules.users.user} = {
            extraGroups = ["docker"];
          };
        };
      };
    };
  }
