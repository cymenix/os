{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ui;
in
  with lib; {
    imports = [
      ./nvim-tree
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              explorer = {
                enable = mkEnableOption "Enable a file explorer" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
