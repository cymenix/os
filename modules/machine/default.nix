{lib, ...}:
with lib; {
  options = {
    modules = {
      machine = {
        kind = mkOption {
          type = types.enum ["desktop" "laptop" "server" "wsl"];
          default = "desktop";
        };
      };
    };
  };
}
