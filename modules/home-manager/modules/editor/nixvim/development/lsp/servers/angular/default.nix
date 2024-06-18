{...}: {
  programs = {
    nixvim = {
      plugins = {
        lsp = {
          postConfig =
            /*
            lua
            */
            ''
              local lsp = require('lspconfig')
              lsp["angularls"].setup({
                cmd = { "ngserver", "--stdio", "--tsProbeLocations", "", "--ngProbeLocations", "" },
                file_types = { "component.html", "component.ts"  },
                root_dir = lsp.util.root_pattern(".angular", ".git"),
              })
            '';
        };
      };
    };
  };
}
