{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development.ui;
in
  with lib; {
    imports = [
      ./catppuccin
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              theme = {
                enable = mkEnableOption "Enable a sexy theme" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
