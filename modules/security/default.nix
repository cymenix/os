{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules;
  user = cfg.users.user;
in
  with lib; {
    imports = [
      ./gnupg
      ./gnome-keyring
      ./sops
      ./tpm
    ];
    options = {
      modules = {
        security = {
          enable = mkEnableOption "Enable common security settings" // {default = cfg.enable;};
        };
      };
    };
    config = mkIf (cfg.enable && cfg.security.enable) {
      environment = {
        systemPackages = [
          (mkIf (config.modules.display.gui != "headless") (import ./polkitagent {inherit pkgs;}))
        ];
      };
      security = {
        rtkit = {
          enable = true;
        };
        polkit = {
          enable = true;
        };
        pam = {
          services = {
            swaylock = {};
            "${user}" = {
              gnupg = {
                enable = true;
              };
            };
          };
        };
        sudo = {
          extraRules = [
            {
              users = [user];
              commands = [
                {
                  command = "ALL";
                  options = ["NOPASSWD" "SETENV"];
                }
              ];
            }
          ];
        };
      };
      users = {
        users = {
          ${user} = {
            extraGroups = ["wheel"];
          };
        };
      };
    };
  }
