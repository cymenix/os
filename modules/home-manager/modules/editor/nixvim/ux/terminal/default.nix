{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ux;
in
  with lib; {
    imports = [
      ./toggleterm
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ux = {
              terminal = {
                enable = mkEnableOption "Enable support for the terminal" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
