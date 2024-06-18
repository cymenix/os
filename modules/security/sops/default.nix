{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.security;
  user = config.modules.users.user;
in {
  imports = [inputs.sops-nix.nixosModules.sops];
  options = {
    modules = {
      security = {
        sops = {
          enable = mkEnableOption "Enable secrets using SOPS" // {default = false;};
          path = mkOption {
            type = types.path;
            default = /home/${user}/${config.modules.users.flake}/secrets;
          };
        };
      };
    };
  };
  config = mkIf (cfg.enable && cfg.sops.enable) {
    environment = {
      systemPackages = [(import ./setupsops.nix {inherit pkgs config;})];
    };
    sops = {
      defaultSopsFile = cfg.sops.path + /secrets.yaml;
      age = {
        keyFile = "/home/${user}/.config/sops/age/keys.txt";
        generateKey = true;
        sshKeyPaths = ["/home/${user}/.ssh/id_ed25519"];
      };
    };
  };
}
