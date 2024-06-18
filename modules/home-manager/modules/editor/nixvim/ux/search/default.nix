{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ux;
in
  with lib; {
    imports = [
      ./telescope
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ux = {
              search = {
                enable = mkEnableOption "Enable the best search" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
