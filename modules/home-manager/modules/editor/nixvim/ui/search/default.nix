{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ui;
in
  with lib; {
    imports = [
      ./searchbox
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              search = {
                enable = mkEnableOption "Enable a better search ui" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
