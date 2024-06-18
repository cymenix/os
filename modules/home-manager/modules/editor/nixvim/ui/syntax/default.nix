{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ui;
in
  with lib; {
    imports = [
      ./indent-blankline
      ./nvim-colorizer
      ./rainbow-delimiters
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              syntax = {
                enable = mkEnableOption "Enable pretty syntax" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
