{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}: let
  iconTheme = pkgs.catppuccin-papirus-folders.override {
    flavor = "macchiato";
    accent = "blue";
  };
  cfg = config.modules.display;
in
  with lib; {
    imports = [
      ./themes
    ];
    options = {
      modules = {
        display = {
          gtk = {
            enable = mkEnableOption "Enable GTK" // {default = cfg.enable;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.gtk.enable && osConfig.modules.display.gtk.enable) {
      home = {
        packages = with pkgs; [
          libsForQt5.breeze-icons
          hicolor-icon-theme
        ];
        file = {
          ".icons/Papirus-Dark" = {
            source = "${iconTheme}/share/icons/Papirus-Dark";
          };
          ".local/share/.icons/Papirus-Dark" = {
            source = "${iconTheme}/share/icons/Papirus-Dark";
          };
        };
      };
      gtk = {
        enable = cfg.gtk.enable;
        cursorTheme = mkForce {
          package = pkgs.catppuccin-cursors.macchiatoBlue;
          name = "catppuccin-macchiato-blue-cursors";
        };
        iconTheme = {
          package = iconTheme;
          name = "Papirus-Dark";
        };
        font = {
          package = pkgs.nerdfonts.override {fonts = ["Iosevka" "VictorMono"];};
          name = "${osConfig.modules.fonts.defaultFont}";
          inherit (osConfig.modules.fonts) size;
        };
        gtk2 = {
          configLocation = "${config.xdg.configHome}/gtk-2.0/settings.ini";
          extraConfig = ''
            gtk-application-prefer-dark-theme=1
          '';
        };
        gtk3 = {
          extraConfig = {
            gtk-application-prefer-dark-theme = 1;
          };
        };
        gtk4 = {
          extraConfig = {
            gtk-application-prefer-dark-theme = 1;
          };
        };
      };
    };
  }
