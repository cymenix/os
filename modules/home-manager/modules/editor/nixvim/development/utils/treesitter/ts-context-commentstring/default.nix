{pkgs, ...}: let
  ts-context-commentstring = pkgs.vimUtils.buildVimPlugin {
    name = "ts-context-commentstring";
    src = pkgs.fetchFromGitHub {
      owner = "mrcjkb";
      repo = "nvim-ts-context-commentstring";
      rev = "ed4655a71848490b5b26538c5825e5fd736fbb01";
      hash = "sha256-fsRyffPK8pJsTPfDr5g1yFiE6+zlNTpGnJQrx+hLoas=";
    };
  };
in {
  programs = {
    nixvim = {
      extraPlugins = [ts-context-commentstring];
      extraConfigLuaPost =
        /*
        lua
        */
        ''
          require('ts_context_commentstring').setup {}
        '';
      plugins = {
        comment = {
          enable = true;
          settings = {
            sticky = true;
            pre_hook =
              /*
              lua
              */
              ''
                require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
              '';
          };
        };
      };
    };
  };
}
