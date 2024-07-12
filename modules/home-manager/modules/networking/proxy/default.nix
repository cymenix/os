{lib, ...}:
with lib; {
  imports = [
    ./charles
  ];
  options = {
    modules = {
      networking = {
        proxy = {
          enable = mkEnableOption "Enable proxy tools" // {default = false;};
        };
      };
    };
  };
}
