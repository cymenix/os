{...}: {
  programs = {
    nixvim = {
      plugins = {
        lsp = {
          servers = {
            nil-ls = {
              enable = true;
              extraOptions = {};
            };
          };
        };
      };
    };
  };
}
