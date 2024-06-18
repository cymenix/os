{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development.languages;
in
  with lib; {
    imports = [
      ./crates-nvim
      ./rustaceanvim
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            development = {
              languages = {
                rust = {
                  enable = mkEnableOption "Enable rust support" // {default = cfg.enable;};
                };
              };
            };
          };
        };
      };
    };
  }
