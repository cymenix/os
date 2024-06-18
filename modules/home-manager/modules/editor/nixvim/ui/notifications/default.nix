{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ui;
in
  with lib; {
    imports = [
      ./notify
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              notifications = {
                enable = mkEnableOption "Enable a neat notification system" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
