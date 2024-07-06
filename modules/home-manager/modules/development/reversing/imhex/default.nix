{
  nixpkgs,
  system,
  config,
  lib,
  ...
}: let
  cfg = config.modules.development.reversing;
  pkgs = import nixpkgs {
    inherit system;
    overlays = [
      (self: super: {
        imhex = super.imhex.overrideAttrs (finalAttrs: previousAttrs:
          with previousAttrs; let
            patterns_version = "1.35.3";
            patterns_src = super.fetchFromGitHub {
              owner = "WerWolv";
              repo = "ImHex-Patterns";
              rev = "ImHex-v${patterns_version}";
              hash = "sha256-h86qoFMSP9ehsXJXOccUK9Mfqe+DVObfSRT4TCtK0rY=";
            };
          in {
            version = "1.35.3";
            src = super.fetchFromGitHub {
              fetchSubmodules = true;
              owner = "WerWolv";
              repo = pname;
              rev = "v${version}";
              hash = "sha256-8vhOOHfg4D9B9yYgnGZBpcjAjuL4M4oHHax9ad5PJtA=";
            };
            postInstall = ''
              mkdir -p $out/share/imhex
              rsync -av --exclude="*_schema.json" ${patterns_src}/{constants,encodings,includes,magic,patterns} $out/share/imhex
            '';
          });
      })
    ];
  };
in
  with lib; {
    options = {
      modules = {
        development = {
          reversing = {
            imhex = {
              enable = mkEnableOption "Enable imhex" // {default = cfg.enable;};
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.imhex.enable) {
      home = {
        packages = with pkgs; [imhex];
      };
    };
  }
