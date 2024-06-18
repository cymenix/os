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
              clipboard = {
                enable = mkEnableOption "Enable clipboard support" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.clipboard.enable) {
      programs = {
        nixvim = {
          clipboard = {
            register = "unnamedplus";
            providers = {
              wl-copy = {
                enable = true;
              };
            };
          };
        };
      };
    };
  }
