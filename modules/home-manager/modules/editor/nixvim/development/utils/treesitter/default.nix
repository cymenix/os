{...}: {
  imports = [
    ./ts-autotag
    ./ts-context-commentstring
  ];
  programs = {
    nixvim = {
      plugins = {
        treesitter = {
          enable = true;
          nixvimInjections = true;
          nixGrammars = true;
        };
      };
    };
  };
}
