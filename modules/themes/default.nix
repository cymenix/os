{
  config,
  lib,
  ...
}: let
  cfg = config.modules;
in
  with lib; {
    imports = [
      ./base
      ./catppuccin
    ];
    options = {
      modules = {
        themes = {
          enable = mkEnableOption "Enable slick themes" // {default = cfg.enable;};
          defaultTheme = mkOption {
            type = types.enum ["catppuccin" "base"];
            default = "catppuccin";
          };
        };
      };
    };
  }
