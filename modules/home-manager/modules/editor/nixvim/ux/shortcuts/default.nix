{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ux;
in
  with lib; {
    imports = [
      ./which-key
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ux = {
              shortcuts = {
                enable = mkEnableOption "Enable the best shortcuts" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
