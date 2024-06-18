{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development.ui;
in
  with lib; {
    imports = [
      ./bufferline
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ui = {
              tabs = {
                enable = mkEnableOption "Enable pretty tabs" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
