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
          (mkIf catppuccin.enable (catppuccin-kvantum.override {inherit (catppuccin) accent flavor;}))
          libsForQt5.qtstyleplugin-kvantum
          libsForQt5.qt5ct
          libsForQt5.qt5.qtwayland
          catppuccin-qt5ct
          catppuccin-kvantum
          qt6.qtwayland
        ];
        sessionVariables = {
          QT_QPA_PLATFOR = "wayland";
          QT_QPA_PLATFORMTHEME = "qt5ct";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          QT_AUTO_SCREEN_SCALE_FACTOR = "1";
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
      xdg.configFile = {
        "Kvantum/Catppuccin-Macchiato-Blue/Catppuccin-Macchiato-Blue/Catppuccin-Macchiato-Blue.kvconfig".source = "${unstablePkgs.catppuccin-kvantum}/share/Kvantum/Catppuccin-Macchiato-Blue/Cattpuccin-Macchiato-Blue.kvconfig";
        "Kvantum/Catppuccin-Macchiato-Blue/Catppuccin-Macchiato-Blue/Catppuccin-Macchiato-Blue.svg".source = "${unstablePkgs.catppuccin-kvantum}/share/Kvantum/Catppuccin-Macchiato-Blue/Cattpuccin-Macchiato-Blue.svg";
      };
    };
  }
