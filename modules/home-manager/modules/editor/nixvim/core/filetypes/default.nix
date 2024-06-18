{
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.core;
in
  with lib; {
    options = {
      modules = {
        editor = {
          nixvim = {
            core = {
              filetypes = {
                enable = mkEnableOption "Enable some core filetype options" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.filetypes.enable) {
      programs = {
        nixvim = {
          filetype = {
            pattern = {
              ".*/hyprland%.conf" = "hyprlang";
              ".*%.component%.html" = "angular.html";
              ".prototools" = "toml";
              ".rasi" = "rasi";
            };
          };
        };
      };
    };
  }
