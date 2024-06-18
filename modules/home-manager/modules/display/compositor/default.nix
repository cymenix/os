{
  config,
  lib,
  ...
}: let
  cfg = config.modules.display;
in
  with lib; {
    imports = [
      ./hyprland
    ];
    options = {
      modules = {
        display = {
          compositor = {
            enable = mkEnableOption "Enable the best compositor" // {default = cfg.enable;};
            defaultCompositor = mkOption {
              type = types.enum ["hyprland"];
              default = "hyprland";
            };
          };
        };
      };
    };
  }
