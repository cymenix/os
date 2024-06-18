{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.security;
in
  with lib; {
    options = {
      modules = {
        security = {
          gnupg = {
            enable = mkEnableOption "Enable gnupg" // {default = cfg.enable;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.gnupg.enable) {
      programs = {
        gnupg = {
          agent = {
            enable = cfg.gnupg.enable;
            enableSSHSupport = true;
          };
        };
      };
      systemd = {
        user = {
          sockets = {
            gpg-agent = {
              listenStreams = let
                socketDir =
                  pkgs.runCommand "gnupg-socketdir" {
                    nativeBuildInputs = [pkgs.python3];
                  } ''
                    ${pkgs.python3}/bin/python3 ${import ./gnupgdir.nix {inherit pkgs;}} '/home/${config.modules.users.user}/.local/share/gnupg' > $out
                  '';
              in [
                "" # unset
                "%t/gnupg/${builtins.readFile socketDir}/S.gpg-agent"
              ];
            };
          };
        };
      };
    };
  }
