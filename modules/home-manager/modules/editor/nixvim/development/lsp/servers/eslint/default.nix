{...}: {
  programs = {
    nixvim = {
      plugins = {
        lsp = {
          servers = {
            eslint = {
              enable = false;
              extraOptions = {};
              rootDir =
                /*
                lua
                */
                ''
                  require('lspconfig').util.root_pattern(".git")
                '';
            };
          };
        };
      };
    };
  };
}
