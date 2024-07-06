{lib, ...}:
with lib; {
  imports = [
    ./ida
  ];
  options = {
    modules = {
      development = {
        reversing = {
          enable = mkEnableOption "Enable reversing support" // {default = false;};
        };
      };
    };
  };
}
