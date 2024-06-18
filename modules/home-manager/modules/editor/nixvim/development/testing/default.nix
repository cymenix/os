{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development;
in
  with lib; {
    imports = [
      ./neotest
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            development = {
              linting = {
                enable = mkEnableOption "Enable testing capabilities" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
