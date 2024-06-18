{...}: {
  programs = {
    nixvim = {
      plugins = {
        lsp = {
          servers = {
            emmet-ls = {
              enable = true;
              extraOptions = {};
              filetypes = [
                "typescript"
                "html"
                "typescriptreact"
                "typescript.tsx"
              ];
            };
          };
        };
      };
    };
  };
}
