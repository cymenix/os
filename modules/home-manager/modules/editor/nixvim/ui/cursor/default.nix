{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ui;
in
  with lib; {
    imports = [
      ./cursorline
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              commandline = {
                enable = mkEnableOption "Enable a cool cursor ui" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
