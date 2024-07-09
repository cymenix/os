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
        ghidra = super.ghidra.overrideAttrs (oldAttrs: {
          patches = oldAttrs.patches ++ [./powerpc.patch];
        });
      })
    ];
    # TODO: install this ghidra extension
    # ps3GhidraScripts = pkgs.stdenv.mkDerivation {
    #   name = "GhidraScripts";
    #   src = pkgs.fetchFromGitHub {
    #     owner = "clienthax";
    #     repo = "Ps3GhidraScripts";
    #   };
    # };
  };
in
  with lib; {
    options = {
      modules = {
        development = {
          reversing = {
            ghidra = {
              enable = mkEnableOption "Enable ghidra" // {default = cfg.enable;};
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.ghidra.enable) {
      home = {
        packages =
          (with pkgs; [
            ghidra
          ])
          ++ (with pkgs.ghidra-extensions; [
            gnudisassembler
            sleighdevtools
            machinelearning
            ghidraninja-ghidra-scripts
          ]);
      };
    };
  }
