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
              options = {
                enable = mkEnableOption "Enable some core options" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.options.enable) {
      programs = {
        nixvim = {
          opts = {
            shiftwidth = 2;
            tabstop = 2;
            scrolloff = 8;
            smartcase = true;
            ignorecase = true;
            number = true;
            undodir = "${config.xdg.dataHome}/nvim/undo";
            signcolumn = "yes";
            wrap = false;
            undofile = true;
            expandtab = true;
            updatetime = 200;
            hlsearch = true;
            virtualedit = "block";
            termguicolors = true;
            syntax = "on";
          };
        };
      };
    };
  }
