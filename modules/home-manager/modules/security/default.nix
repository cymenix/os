{
  lib,
  config,
  ...
}: let
  cfg = config.modules;
in
  with lib; {
    imports = [
      ./bitwarden
      ./ssh
      ./gpg
      ./sops
    ];
    options = {
      modules = {
        security = {
          enable = mkEnableOption "Enable tools for security" // {default = cfg.enable;};
        };
      };
    };
  }
