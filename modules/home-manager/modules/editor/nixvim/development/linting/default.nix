{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development;
in
  with lib; {
    imports = [
      ./lint
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            development = {
              linting = {
                enable = mkEnableOption "Enable linting capabilities" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
