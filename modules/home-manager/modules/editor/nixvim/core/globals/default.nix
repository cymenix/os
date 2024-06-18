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
              globals = {
                enable = mkEnableOption "Enable some core global options" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.globals.enable) {
      programs = {
        nixvim = {
          globals = {
            mapleader = " ";
            loaded_node_provider = 0;
            loaded_python3_provider = 0;
            loaded_perl_provider = 0;
            loaded_ruby_provider = 0;
          };
        };
      };
    };
  }
