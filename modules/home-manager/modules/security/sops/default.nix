{
  lib,
  config,
  osConfig,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.security;
  inherit (osConfig.modules.users) user flake;
in {
  imports = [
    inputs.sops-nix.homeManagerModule
  ];
  options = {
    modules = {
      security = {
        sops = {
          enable = mkEnableOption "Enable secrets using SOPS" // {default = false;};
          path = mkOption {
            type = types.path;
            default = /home/${user}/${flake}/secrets;
          };
        };
      };
    };
  };
  config = mkIf (osConfig.modules.security.sops.enable && cfg.enable && cfg.sops.enable) {
    sops = {
      defaultSopsFile = cfg.sops.path + /secrets.yaml;
      age = {
        keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
        generateKey = true;
        sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
      };
    };
  };
}
