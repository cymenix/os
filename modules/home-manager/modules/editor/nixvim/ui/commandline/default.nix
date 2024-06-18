{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ui;
in
  with lib; {
    imports = [
      ./fine-cmdline
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              commandline = {
                enable = mkEnableOption "Enable a cool command line" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
