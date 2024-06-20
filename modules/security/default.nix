{
  config,
  lib,
  ...
}: let
  cfg = config.modules;
in
  with lib; {
    imports = [
      ./gnome-keyring
      ./gnupg
      ./polkit
      ./rtkit
      ./sops
      ./ssh
      ./sudo
      ./swaylock
      ./tpm
    ];
    options = {
      modules = {
        security = {
          enable = mkEnableOption "Enable common security settings" // {default = cfg.enable;};
        };
      };
    };
  }
