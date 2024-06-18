{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development.languages;
in
  with lib; {
    imports = [
      ./vimtex
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            development = {
              languages = {
                latex = {
                  enable = mkEnableOption "Enable latex support" // {default = cfg.enable;};
                };
              };
            };
          };
        };
      };
    };
  }
