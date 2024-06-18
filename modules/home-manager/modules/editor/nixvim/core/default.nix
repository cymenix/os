{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim;
in
  with lib; {
    imports = [
      ./autocommands
      ./clipboard
      ./editorconfig
      ./filetypes
      ./globals
      ./keymaps
      ./options
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            core = {
              enable = mkEnableOption "Enable core neovim configuration" // {default = cfg.enable;};
            };
          };
        };
      };
    };
  }
