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
          gnome-keyring = {
            enable = mkEnableOption "Enable gnome-keyring" // {default = cfg.enable;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.gnome-keyring.enable) {
      services = {
        gnome = {
          gnome-keyring = {
            enable = cfg.gnome-keyring.enable;
          };
        };
      };
    };
  }
