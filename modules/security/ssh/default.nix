{
  config,
  lib,
  ...
}: let
  cfg = config.modules.security;
in
  with lib; {
    options = {
      modules = {
        security = {
          ssh = {
            enable = mkEnableOption "Enable SSH" // {default = cfg.enable;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.ssh.enable) {
      services = {
        openssh = {
          inherit (cfg.ssh) enable;
        };
      };
    };
  }
