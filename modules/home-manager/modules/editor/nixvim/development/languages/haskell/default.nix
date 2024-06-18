{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development.languages;
in
  with lib; {
    imports = [
      ./haskell-tools-nvim
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            development = {
              languages = {
                haskell = {
                  enable = mkEnableOption "Enable haskell support" // {default = cfg.enable;};
                };
              };
            };
          };
        };
      };
    };
  }
