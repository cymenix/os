{
  pkgs,
  config,
}: let
  cfg = config.modules.users;
  inherit (cfg) user flake;
in
  pkgs.writeShellScriptBin "setupsops" ''
    ${pkgs.toybox}/bin/mkdir -p ~/.config/sops/age
    ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
    ${pkgs.age}/bin/age-keygen -y ~/.config/sops/age/keys.txt
    cd /home/${user}/${flake}/secrets || exit
    ${pkgs.sops}/bin/sops secrets.yaml
  ''
