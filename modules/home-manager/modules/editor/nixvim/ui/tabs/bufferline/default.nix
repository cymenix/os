{...}: {
  programs = {
    nixvim = {
      plugins = {
        bufferline = {
          enable = true;
          alwaysShowBufferline = true;
          showCloseIcon = true;
          showBufferIcons = true;
          showTabIndicators = true;
          colorIcons = true;
          themable = true;
          mode = "buffers";
          separatorStyle = "thin";
          diagnostics = "nvim_lsp";
          closeIcon = "";
          bufferCloseIcon = "";
          modifiedIcon = "●";
          leftTruncMarker = "";
          rightTruncMarker = "";
          indicator = {
            icon = "▎";
            style = "icon";
          };
          hover = {
            enabled = true;
          };
          highlights = {
            fill = {
              bg = "#1E1F38";
            };
          };
        };
      };
    };
  };
}
