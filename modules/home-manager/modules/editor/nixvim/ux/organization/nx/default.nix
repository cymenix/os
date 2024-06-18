{
  pkgs,
  config,
  lib,
  ...
}: let
  nx = pkgs.vimUtils.buildVimPlugin {
    name = "nx";
    src = pkgs.fetchFromGitHub {
      owner = "clemenscodes";
      repo = "nx.nvim";
      rev = "08769c518e4b590c1fdcddcc1cc1f6ea6cbd821f";
      hash = "sha256-dYP+1LzMTe8UCYq+opWtNPWweIdKDcTbrzKYxo5L0j4=";
    };
  };
  cfg = config.modules.editor.nixvim;
in
  with lib; {
    options = {
      modules = {
        editor = {
          nixvim = {
            nx = {
              enable = mkEnableOption "Enable nx support for nixvim" // {default = false;};
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.nx.enable) {
      programs = {
        nixvim = {
          extraPlugins = [nx];
          extraConfigLuaPost =
            /*
            lua
            */
            ''
              require('nx').setup{
                  nx_cmd_root = 'nx',
                  command_runner = require('nx.command-runners').toggleterm_runner()
              }
            '';
          keymaps = [
            {
              action = ":Telescope nx actions<CR>";
              key = "<leader>xa";
              mode = "n";
              options = {
                silent = true;
                desc = "Find nx actions";
              };
            }
            {
              action = ":Telescope nx generators<CR>";
              key = "<leader>xg";
              mode = "n";
              options = {
                silent = true;
                desc = "Find nx generators";
              };
            }
            {
              action = ":Telescope nx affected<CR>";
              key = "<leader>xf";
              mode = "n";
              options = {
                silent = true;
                desc = "Find nx affected targets";
              };
            }
            {
              action = ":Telescope nx run_many<CR>";
              key = "<leader>xm";
              mode = "n";
              options = {
                silent = true;
                desc = "Find nx run many targets";
              };
            }
          ];
          plugins = {
            which-key = {
              registrations = {
                "<leader>x" = {
                  name = "+Nx";
                  a = "Nx actions";
                  g = "Nx generators";
                  f = "Nx affected";
                  m = "Nx run-many";
                };
              };
            };
          };
        };
      };
    };
  }
