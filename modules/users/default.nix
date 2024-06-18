{
  lib,
  config,
  ...
}: let
  cfg = config.modules;
in
  with lib; {
    options = {
      modules = {
        users = {
          enable = mkEnableOption "Enable user settings" // {default = cfg.enable;};
          user = mkOption {
            type = types.str;
            default = "nixos";
          };
          name = mkOption {
            type = types.str;
            default = cfg.users.user;
          };
          uid = mkOption {
            type = types.int;
            default = 1000;
          };
          flake = mkOption {
            type = types.str;
            default = ".local/src/${cfg.hostname.defaultHostname}";
            description = "Where the flake will be, relative to the users home directory";
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.users.enable) {
      users = {
        mutableUsers = true;
        defaultUserShell = cfg.shell.defaultShell;
        users = {
          ${cfg.users.user} = {
            isNormalUser = true;
            description = cfg.users.user;
            group = cfg.users.user;
            hashedPasswordFile = mkIf cfg.security.sops.enable config.sops.secrets.password.path;
          };
        };
        groups = {
          ${cfg.users.user} = {};
        };
      };
    };
  }
