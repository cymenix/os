{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim;
in
  with lib; {
    imports = [
      ./commandline
      ./cursor
      ./explorer
      ./notifications
      ./prompts
      ./scope
      ./search
      ./startup
      ./status
      ./syntax
      ./tabs
      ./tags
      ./theme
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              enable = mkEnableOption "Enable a beatiful neovim ui" // {default = cfg.enable;};
            };
          };
        };
      };
    };
  }
