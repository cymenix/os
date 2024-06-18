{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim;
in
  with lib; {
    imports = [
      ./completion
      ./debugging
      ./formatting
      ./languages
      ./linting
      ./lsp
      ./snippets
      ./testing
      ./utils
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            development = {
              enable = mkEnableOption "Enable powerful development capabilities" // {default = cfg.enable;};
            };
          };
        };
      };
    };
  }
