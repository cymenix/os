{
  pkgs,
  inputs,
  system,
  config,
  lib,
  ...
}: let
  aiken-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "aiken-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "aiken-lang";
      repo = "editor-integration-nvim";
      rev = "bcad7adea6b99f00e63c405f558c6d16a7f6ecb7";
      hash = "sha256-GFJmpE5J8DNjvmoGdDpy9JWhd2g+oKoEKVphbvuBAFQ=";
    };
  };
  cfg = config.modules.editor;
  useCardano = config.modules.development.cardano.enable;
in
  with lib; {
    options = {
      modules = {
        editor = {
          nixvim = {
            aiken = {
              enable = mkEnableOption "Enable aiken support" // {default = cfg.enable && useCardano;};
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.nixvim.enable && cfg.nixvim.aiken.enable && useCardano) {
      programs = {
        nixvim = {
          extraPackages = with inputs.aiken.packages.${system}; [
            aiken
          ];
          extraPlugins = [aiken-nvim];
          plugins = {
            lsp = {
              postConfig =
                /*
                lua
                */
                ''
                  require('lspconfig')["aiken"].setup({
                    cmd = { "aiken", "lsp" },
                    file_types = { "aiken" },
                  })
                '';
            };
          };
        };
      };
    };
  }
