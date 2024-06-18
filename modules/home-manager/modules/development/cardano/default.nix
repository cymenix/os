{
  lib,
  config,
  ...
}: let
  cfg = config.modules.development;
in
  with lib; {
    imports = [
      ./aiken
      ./cardano-node
      ./cardano-cli
      ./cardano-wallet
    ];
    options = {
      modules = {
        development = {
          cardano = {
            enable = mkEnableOption "Enable Cardano development support" // {default = false;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.cardano.enable) {
      nix = {
        settings = {
          substituters = ["https://cache.iog.io"];
          trusted-public-keys = ["hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="];
        };
      };
    };
  }
