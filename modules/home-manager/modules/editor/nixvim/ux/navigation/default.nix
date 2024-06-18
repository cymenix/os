{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ux;
in
  with lib; {
    imports = [
      ./hardtime
      ./leap
      ./tmux-navigator
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ux = {
              navigation = {
                enable = mkEnableOption "Enable a nicer navigation" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
