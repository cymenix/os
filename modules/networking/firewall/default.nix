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
      networking = {
        dhcpcd = {
          denyInterfaces = ["virbr0"];
        };
        firewall = {
          enable = cfg.firewall.enable;
          allowedTCPPorts = [vnc];
          extraCommands = ''
            iptables -A FORWARD -s 192.168.2.0/24 -d 192.168.122.0/24 -o virbr0 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
            iptables -D FORWARD -o virbr0 -p tcp -d ${vmip} --dport ${builtins.toString vnc} -j ACCEPT
            iptables -t nat -D PREROUTING -p tcp --dport ${builtins.toString vnc} -j DNAT --to ${vmip}:${builtins.toString vnc}
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
