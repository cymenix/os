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
        useDHCP = false;
        firewall = {
          enable = cfg.firewall.enable;
        };
        bridges = {
          br0 = {
            interfaces = ["enp5s0"];
          };
        };
        interfaces = {
          br0 = {
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
        dhcpcd = {
          denyInterfaces = ["virbr0" "br0"];
        };
      };
    };
  }
