{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.monitoring;
in
  with lib; {
    options = {
      modules = {
        monitoring = {
          wireshark = {
            enable = mkEnableOption "Enable wireshark" // {default = cfg.enable;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.wireshark.enable) {
      home = {
        packages = with pkgs; [wireshark];
      };
    };
  }
