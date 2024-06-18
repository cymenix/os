{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development;
in
  with lib; {
    imports = [
      ./conform-nvim
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            development = {
              formatting = {
                enable = mkEnableOption "Enable formatting capabilities" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
