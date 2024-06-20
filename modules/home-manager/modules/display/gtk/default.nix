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
        theme = mkForce {
          name = "Catppuccin-Macchiato-Blue-Standard-Dark";
          package = pkgs.catppuccin-gtk.override {
            accents = ["blue"];
            tweaks = ["black" "rimless"];
            variant = "macchiato";
          };
        };
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
      };
      xdg.configFile = {
        "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
        "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
        "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
      };
    };
  }
