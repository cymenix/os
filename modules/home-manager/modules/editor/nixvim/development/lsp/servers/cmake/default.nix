{...}: {
  programs = {
    nixvim = {
      plugins = {
        lsp = {
          servers = {
            cmake = {
              enable = false;
              extraOptions = {};
            };
          };
        };
      };
    };
  };
}
