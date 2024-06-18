{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development;
in
  with lib; {
    imports = [
      ./cmp
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            development = {
              completion = {
                enable = mkEnableOption "Enable completion capabilities" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
