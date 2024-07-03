{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.networking;
in {
  options = {
    modules = {
      networking = {
        torrent = {
          enable = mkEnableOption "Enable torrenting" // {default = cfg.enable;};
        };
      };
    };
  };
  config = mkIf (cfg.enable && cfg.torrent.enable) {
    networking = {
      nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
    };
    services = {
      resolved = {
        enable = true;
        dnssec = "true";
        domains = ["~."];
        fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
        dnsovertls = "true";
      };
      mullvad-vpn = {
        enable = true;
        package = pkgs.mullvad-vpn;
      };
    };
    # systemd = {
    #   services = {
    #     mullvad-daemon = {
    #       postStart = let
    #         mullvad = config.services.mullvad-vpn.package;
    #       in ''
    #         while ! ${mullvad}/bin/mullvad status >/dev/null; do sleep 1; done
    #         ${mullvad}/bin/mullvad auto-connect set on
    #         ${mullvad}/bin/mullvad tunnel ipv6 set on
    #         ${mullvad}/bin/mullvad set default \
    #             --block-ads --block-trackers --block-malware
    #       '';
    #     };
    #   };
    # };
    environment = {
      systemPackages = with pkgs; [
        qbittorrent
        mullvad
        mullvad-vpn
        wireguard-tools
      ];
    };
  };
}
