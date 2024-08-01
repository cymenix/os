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
        };
        bridges = {
          br0 = {
            interfaces = ["wlp4s0"];
          };
        };
        interfaces = {
          br0 = {
            useDHCP = false;
            ipv4 = {
              addresses = [
                {
                  address = "192.168.1.116";
                  prefixLength = 24;
                }
              ];
            };
          };
        };
      };
    };
  }
