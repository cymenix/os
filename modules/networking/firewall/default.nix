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
          wlp4s0 = {
            useDHCP = true;
          };
          br0 = {
            useDHCP = true;
          };
        };
      };
    };
  }
