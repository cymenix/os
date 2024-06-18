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
              autocommands = {
                enable = mkEnableOption "Enable some core autocommands" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.autocommands.enable) {
      programs = {
        nixvim = {
          autoCmd = [
            {
              event = ["BufReadCmd"];
              pattern = "*.pdf";
              callback.__raw =
                /*
                lua
                */
                ''
                  function()
                    local filename = vim.fn.shellescape(vim.api.nvim_buf_get_name(0))
                    vim.cmd("silent !zathura " .. filename .. " &")
                    vim.cmd("let tobedeleted = bufnr('%') | b# | exe \"bd! \" . tobedeleted")
                  end
                '';
            }
            {
              event = ["BufReadCmd"];
              pattern = [
                "*.png"
                "*.jpg"
                "*.jpeg"
                "*.gif"
                "*.webp"
              ];
              callback.__raw =
                /*
                lua
                */
                ''
                  function()
                    local filename = vim.fn.shellescape(vim.api.nvim_buf_get_name(0))
                    vim.cmd("silent !swayimg " .. filename .. " &")
                    vim.cmd("let tobedeleted = bufnr('%') | b# | exe \"bd! \" . tobedeleted")
                  end
                '';
            }
          ];
        };
      };
    };
  }
