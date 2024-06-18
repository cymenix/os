{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ui;
in
  with lib; {
    imports = [
      ./alpha
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              startup = {
                enable = mkEnableOption "Enable a cool startup screen" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
