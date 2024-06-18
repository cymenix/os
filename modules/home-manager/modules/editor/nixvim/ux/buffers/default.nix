{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.ux;
in
  with lib; {
    imports = [
      ./vim-bbye
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            ux = {
              buffers = {
                enable = mkEnableOption "Enable better buffer handling" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
