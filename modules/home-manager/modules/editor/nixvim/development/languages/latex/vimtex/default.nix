{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim;
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full;
  };
  viewer = "zathura_simple";
in
  with lib; {
    options = {
      modules = {
        editor = {
          nixvim = {
            vimtex = {
              enable = mkEnableOption "Enable vimtex" // {default = false;};
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.vimtex.enable) {
      programs = {
        nixvim = {
          globals = {
            maplocalleader = ",";
            vimtex_view_method = viewer;
            latex_view_general_viewer = viewer;
          };
          extraPackages = [tex];
          extraPlugins = with pkgs.vimPlugins; [vimtex];
        };
      };
    };
  }
