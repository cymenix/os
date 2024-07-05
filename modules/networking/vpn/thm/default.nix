{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.networking.vpn;
  thmvpn = pkgs.writeShellScriptBin "thmvpn" ''
    PROTOCOL="anyconnect"
    SERVER="vpn.thm.de"
    USERNAME="''${1:-chrn48}"
    PASSWORD="''${2:-$(${pkgs.bat}/bin/bat ${cfg.thm.passwordFile} --style=plain)}"
    echo "$PASSWORD" | sudo ${pkgs.openconnect}/bin/openconnect --protocol=$PROTOCOL --server=$SERVER --user=$USERNAME --passwd-on-stdin
  '';
in {
  options = {
    modules = {
      networking = {
        vpn = {
          thm = {
            enable = mkEnableOption "Enable THM VPN using openconnect" // {default = false;};
            passwordFile = mkOption {
              type = types.path;
            };
          };
        };
      };
    };
  };
  config = mkIf (cfg.enable && cfg.thm.enable) {
    environment = {
      systemPackages = [thmvpn];
    };
  };
}
