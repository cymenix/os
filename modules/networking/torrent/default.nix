{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.networking;
  nameservers = [
    "194.242.2.2#dns.mullvad.net"
    "194.242.2.3#adblock.dns.mullvad.net"
    "194.242.2.4#base.dns.mullvad.net"
    "194.242.2.5#extended.dns.mullvad.net"
    "194.242.2.6#family.dns.mullvad.net"
    "194.242.2.9#all.dns.mullvad.net"
  ];
in {
  options = {
    modules = {
      networking = {
        torrent = {
          enable = mkEnableOption "Enable torrenting" // {default = cfg.enable;};
          mullvadAccountSecretPath = mkOption {
            type = types.path;
          };
        };
      };
    };
  };
  config = mkIf (cfg.enable && cfg.torrent.enable) {
    networking = {
      nameservers = ["194.242.2.9#all.dns.mullvad.net"];
    };
    services = {
      resolved = {
        enable = true;
        dnssec = "true";
        domains = ["~."];
        fallbackDns = nameservers;
        dnsovertls = "true";
      };
      mullvad-vpn = {
        enable = true;
        package = pkgs.mullvad-vpn;
      };
    };
    systemd = {
      services = {
        mullvad-daemon = {
          postStart = let
            mullvad = config.services.mullvad-vpn.package;
          in ''
            while ! ${mullvad}/bin/mullvad status >/dev/null; do sleep 1; done
            ${mullvad}/bin/mullvad account login $(${pkgs.bat}/bin/bat ${cfg.torrent.mullvadAccountSecretPath} --style=plain)
            ${mullvad}/bin/mullvad auto-connect set on
            ${mullvad}/bin/mullvad tunnel ipv6 set on
            ${mullvad}/bin/mullvad set default \
                --block-ads --block-trackers --block-malware
          '';
        };
      };
    };
    environment = {
      systemPackages = with pkgs; [
        qbittorrent
        mullvad
        mullvad-vpn
      ];
    };
  };
}
