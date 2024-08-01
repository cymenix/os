{
  lib,
  config,
  ...
}: let
  cfg = config.modules.networking;
in
  with lib; {
    options = {
      modules = {
        networking = {
          firewall = {
            enable = mkEnableOption "Enable firewall" // {default = cfg.enable;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.firewall.enable) {
      networking = {
        firewall = {
          enable = cfg.firewall.enable;
          allowedTCPPorts = [
            5900 # VNC
          ];
        };
      };
    };
  }
