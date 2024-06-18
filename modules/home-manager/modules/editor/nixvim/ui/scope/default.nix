{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ui;
in
  with lib; {
    imports = [
      ./winbar
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              scope = {
                enable = mkEnableOption "Enable a better scope ui" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
