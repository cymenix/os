{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development;
in
  with lib; {
    imports = [
      ./haskell
      ./latex
      ./rust
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            development = {
              languages = {
                enable = mkEnableOption "Enable support for various languages" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
