{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.security;
  inherit (config.modules.users) user;
in {
  imports = [inputs.sops-nix.nixosModules.sops];
  options = {
    modules = {
      security = {
        sops = {
          enable = mkEnableOption "Enable secrets using SOPS" // {default = false;};
        };
      };
    };
  };
  config = mkIf (cfg.enable && cfg.sops.enable) {
    environment = {
      systemPackages = [(import ./setupsops.nix {inherit pkgs config;})];
    };
    sops = {
      age = {
        keyFile = "/home/${user}/.config/sops/age/keys.txt";
        generateKey = true;
        sshKeyPaths = ["/home/${user}/.ssh/id_ed25519"];
      };
    };
  };
}
