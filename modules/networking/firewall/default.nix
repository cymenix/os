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
        nat = {
          enable = true;
          externalInterface = "wlp0s20f3";
          externalIP = "192.168.178.175";
          internalInterfaces = ["wlp4s0" "virbr0"];
          forwardPorts = [
            {
              destination = "192.168.122.1:5900";
              proto = "tcp";
              sourcePort = 5900;
            }
          ];
        };
        dhcpcd = {
          denyInterfaces = ["virbr0"];
        };
      };
    };
  }
