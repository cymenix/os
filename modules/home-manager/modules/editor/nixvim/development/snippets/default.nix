{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development;
in
  with lib; {
    imports = [
      ./friendly-snippets
      ./luasnip
    ];
    options = {
      modules = {
        editor = {
          nixvim = {
            development = {
              snippet = {
                enable = mkEnableOption "Enable snippet capabilities" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
