{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ux;
in
  with lib; {
    imports = [
      ./trouble
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ux = {
              diagnostics = {
                enable = mkEnableOption "Enable great diagnostics" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
