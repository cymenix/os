{
  lib,
  config,
  ...
}: let
  cfg = config.modules.config;
  user = config.modules.users.user;
in
  with lib; {
    options = {
      modules = {
        config = {
          nix = {
            enable = mkEnableOption "Enable common nix options" // {default = cfg.enable;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.nix.enable) {
      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
        optimise = {
          automatic = true;
        };
        settings = {
          auto-optimise-store = true;
          trusted-users = ["root" user];
          experimental-features = [
            "nix-command"
            "flakes"
            "repl-flake"
          ];
        };
      };
    };
  }
