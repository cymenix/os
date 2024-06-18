{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development;
in
  with lib; {
    imports = [
      ./neodev
      ./treesitter
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            development = {
              utils = {
                enable = mkEnableOption "Enable development utilities" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
