{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}: let
  cfg = config.modules.display;
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
          libsForQt5.qt5.qtwayland
          qt6.qtwayland
        ];
      };
      qt = {
        enable = cfg.qt.enable;
        platformTheme = {
          name = "gtk";
        };
        style = {
          catppuccin = mkIf (osConfig.modules.themes.catppuccin.enable) {
            inherit (osConfig.modules.themes.catppuccin) enable flavor;
          };
        };
      };
    };
  }
