{...}: {
  programs = {
    nixvim = {
      plugins = {
        lsp = {
          servers = {
            bashls = {
              enable = false;
              extraOptions = {};
            };
          };
        };
      };
    };
  };
}
