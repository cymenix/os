{
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor;
in
  with lib; {
    imports = [inputs.nvim.homeManagerModules.default];
    options = {
      modules = {
        editor = {
          nvim = {
            enable = mkEnableOption "Enable nvim" // {default = cfg.enable;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.nvim.enable) {
      modules = {
        editor = {
          nixvim = {
            inherit (cfg.nixvim) enable;
          };
        };
      };
    };
  }
