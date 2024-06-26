{
  pkgs,
  config,
  lib,
  ...
}: let
  dlplaylist = pkgs.writeShellScriptBin "dlplaylist" ''
    playlist_url=$1
    ${pkgs.yt-dlp}/bin/yt-dlp  --yes-playlist -o '$XDG_MUSIC_DIR/%(title)s.%(ext)s' -f 'bestaudio/best' --extract-audio --audio-format opus $playlist_url
  '';
  cfg = config.modules.media.music;
in
  with lib; {
    options = {
      modules = {
        media = {
          music = {
            dlplaylist = {
              enable = mkEnableOption "Enable dlplaylist script to download youtube playlists" // {default = cfg.enable;};
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.dlplaylist.enable) {
      home = {
        packages = [dlplaylist];
      };
    };
  }
