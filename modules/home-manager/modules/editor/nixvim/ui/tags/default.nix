{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development.ui;
in
  with lib; {
    imports = [
      ./tagbar
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              tags = {
                enable = mkEnableOption "Enable tag support" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
