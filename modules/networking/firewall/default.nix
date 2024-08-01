{
  lib,
  config,
  ...
}: let
  cfg = config.modules.networking;
  vmip = "192.168.122.1";
  vnc = 5900;
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
      boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = 1;
        "net.ipv4.conf.default.forwarding" = 1;
      };
      networking = {
        dhcpcd = {
          denyInterfaces = ["virbr0"];
        };
        firewall = {
          enable = cfg.firewall.enable;
          allowedTCPPorts = [vnc];
          extraCommands = ''
            iptables -t nat -A POSTROUTING -d ${vmip} -p tcp -m tcp --dport ${builtins.toString vnc} -j MASQUERADE
          '';
        };
        nat = {
          enable = true;
          externalInterface = "virbr0";
          internalInterfaces = ["wlp4s0"];
          externalIP = "192.168.178.175";
          forwardPorts = [
            {
              destination = "${vmip}:${builtins.toString vnc}";
              proto = "tcp";
              sourcePort = vnc;
            }
          ];
        };
      };
    };
  }
