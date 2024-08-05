{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.gaming.wine;
  # pkgs = import nixpkgs {
  #   inherit system;
  #   overlays = [
  #     (final: prev: {
  #       w3c-wine = prev.mkDerivation {
  #         name = "w3c-wine";
  #         src = prev.fetchFromGitHub {
  #
  #         };
  #       };
  #     })
  #   ];
  # };
in
  with lib; {
    options = {
      modules = {
        gaming = {
          wine = {
            wc3 = {
              enable = mkEnableOption "Enable wc3" // {default = cfg.enable;};
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.wc3.enable) {
      home-manager = {
        users = {
          ${user} = {
            home = {
              packages = with pkgs; [wineWowPackages.stagingFull];
            };
          };
        };
      };
    };
  }
