{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ux;
in
  with lib; {
    imports = [
      ./auto-save
      ./better-escape
      ./nix-develop
      ./nvim-autopairs
      ./project-nvim
      ./surround
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ux = {
              ergonomics = {
                enable = mkEnableOption "Enable amazing ergonomics" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
