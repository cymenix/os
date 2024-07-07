{
  lib,
  config,
  ...
}: let
  cfg = config.modules.networking;
in
  with lib; {
    imports = [
      ./pidgin
    ];
    options = {
      modules = {
        networking = {
          irc = {
            enable = mkEnableOption "Enable irc" // {default = cfg.enable;};
          };
        };
      };
    };
  }
