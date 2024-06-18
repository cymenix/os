{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.editor.nixvim.development.languages.haskell;
in
  with lib; {
    options = {
      modules = {
        editor = {
          nixvim = {
            development = {
              languages = {
                haskell = {
                  haskell-tools-nvim = {
                    enable = mkEnableOption "Enable haskell support" // {default = false;};
                  };
                };
              };
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.haskell-tools-nvim.enable) {
      programs = {
        nixvim = {
          extraPlugins = with pkgs.vimPlugins; [
            haskell-tools-nvim
          ];
          extraPackages = with pkgs.haskellPackages; [
            hoogle
            haskell-debug-adapter
            ghci-dap
            fast-tags
          ];
          extraConfigLuaPost =
            /*
            lua
            */
            ''
              require('telescope').load_extension('ht')
            '';
          plugins = {
            which-key = {
              registrations = {
                "<leader>th" = "Toggle Cabal REPL";
              };
            };
          };
          keymaps = [
            {
              action.__raw =
                /*
                lua
                */
                ''
                  function()
                    require('haskell-tools').repl.toggle()
                  end
                '';
              key = "<leader>th";
              mode = "n";
              options = {
                silent = true;
                desc = "Toggle Cabal REPL";
              };
            }
          ];
        };
      };
    };
  }
