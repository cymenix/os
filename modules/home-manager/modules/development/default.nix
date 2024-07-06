{
  lib,
  config,
  ...
}: let
  cfg = config.modules;
in
  with lib; {
    imports = [
      ./c
      ./cardano
      ./corepack
      ./direnv
      ./gh
      ./git
      ./lazygit
      ./gitui
      ./node
      ./reversing
    ];
    options = {
      modules = {
        development = {
          enable = mkEnableOption "Enable development tools" // {default = cfg.enable;};
        };
      };
    };
  }
