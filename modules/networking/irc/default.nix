{
  lib,
  config,
  ...
}: let
  cfg = config.modules.organization;
in
  with lib; {
    imports = [
      ./weechat
    ];
    options = {
      modules = {
        organization = {
          irc = {
            enable = mkEnableOption "Enable irc" // {default = cfg.enable;};
          };
        };
      };
    };
  }
