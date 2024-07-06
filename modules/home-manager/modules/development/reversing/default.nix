{lib, ...}:
with lib; {
  imports = [
    ./ghidra
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
