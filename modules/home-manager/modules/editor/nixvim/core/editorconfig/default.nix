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
              editorconfig = {
                enable = mkEnableOption "Enable editorconfig support" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.editorconfig.enable) {
      programs = {
        nixvim = {
          editorconfig = {
            enable = cfg.editorconfig.enable;
            properties = {};
          };
        };
      };
    };
  }
