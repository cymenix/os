{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development;
in
  with lib; {
    imports = [
      ./dap
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            development = {
              debugging = {
                enable = mkEnableOption "Enable debugging capabilities" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
