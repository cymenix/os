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
      boot = {
        kernel = {
          sysctl = {
            "net.ipv4.ip_forward" = "1";
          };
        };
      };
      networking = {
        firewall = let
          vnc = 5900;
        in {
          enable = cfg.firewall.enable;
          allowedTCPPorts = [vnc];
          extraCommands = ''
            iptables -A FORWARD -o virbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT
            iptables -A FORWARD -i virbr0 -o wlp4s0 -j ACCEPT
            iptables -t nat -A POSTROUTING -s 192.168.122.0/24 -o eth0 -j MASQUERADE
            iptables -t nat -A PREROUTING -i wlp4s0 -p tcp --dport 5900 -j DNAT --to-destination 192.168.122.100:5900
          '';
        };
      };
    };
  }
