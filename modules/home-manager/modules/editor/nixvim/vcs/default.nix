{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim;
in
  with lib; {
    imports = [
      ./gitsigns
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            vcs = {
              enable = mkEnableOption "Enable a great version control integration" // {default = cfg.enable;};
            };
          };
        };
      };
    };
  }
