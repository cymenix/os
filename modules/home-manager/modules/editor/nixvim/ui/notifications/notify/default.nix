{...}: {
  programs = {
    nixvim = {
      extraConfigLuaPost =
        /*
        lua
        */
        ''
          vim.notify = vim.schedule_wrap(require("notify"))
        '';
      plugins = {
        notify = {
          enable = true;
          topDown = false;
          timeout = 3000;
          maxWidth = 200;
          render = "minimal";
        };
      };
    };
  };
}
