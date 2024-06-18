{pkgs, ...}: let
  ts-context-commentstring = pkgs.vimUtils.buildVimPlugin {
    name = "ts-context-commentstring";
    src = pkgs.fetchFromGitHub {
      owner = "mrcjkb";
      repo = "nvim-ts-context-commentstring";
      rev = "c6eebaa0288ec7c0b3df9fcef83fc4ae8bb39c49";
      hash = "sha256-O+5wJtWFs4ZxD9q0+SxR9ggd5amUdnoTbRItaN7rB5E=";
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
