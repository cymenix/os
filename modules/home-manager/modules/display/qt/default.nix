{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}: let
  cfg = config.modules.display;
  catppuccin = osConfig.modules.themes.catppuccin;
in
  with lib; {
    options = {
      modules = {
        display = {
          qt = {
            enable = mkEnableOption "Enable Qt" // {default = cfg.enable;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.qt.enable) {
      home = {
        packages = with pkgs; [
          (mkIf catppuccin.enable (catppuccin-kvantum.override {inherit (catppuccin) enable flavor;}))
          libsForQt5.qtstyleplugin-kvantum
          libsForQt5.qt5ct
          libsForQt5.qt5.qtwayland
          catppuccin-qt5ct
          catppuccin-kvantum
          qt6.qtwayland
        ];
        sessionVariables = {
          QT_QPA_PLATFORMTHEME = "qt5ct";
        };
      };
      qt = {
        enable = cfg.qt.enable;
        platformTheme = {
          name = "qtct";
        };
        style = {
          name = "kvantum";
          package = pkgs.catppuccin-kvantum;
          catppuccin = mkIf (osConfig.modules.themes.catppuccin.enable) {
            inherit (osConfig.modules.themes.catppuccin) enable flavor;
          };
        };
      };
      xdg = {
        configFile = {
          kvantum = {
            target = "Kvantum/kvantum.kvconfig";
            text = lib.generators.toINI {} {
              General.theme = "Catppuccin-Macchiato-Blue";
            };
          };
          qt5ct = {
            target = "qt5ct/qt5ct.conf";
            text = lib.generators.toINI {} {
              Appearance = {
                icon_theme = "Papirus-Dark";
              };
            };
          };
          qt6ct = {
            target = "qt6ct/qt6ct.conf";
            text = lib.generators.toINI {} {
              Appearance = {
                icon_theme = "Papirus-Dark";
              };
            };
          };
        };
      };
    };
  }
