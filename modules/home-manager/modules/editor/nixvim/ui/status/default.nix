{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ui;
in
  with lib; {
    imports = [
      ./lualine
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              status = {
                enable = mkEnableOption "Enable a hot status bar" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
