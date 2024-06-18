{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ui;
in
  with lib; {
    imports = [
      ./dressing
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              notifications = {
                enable = mkEnableOption "Enable prettier prompts" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
