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
  };
  ps3GhidraScripts = pkgs.stdenv.mkDerivation {
    name = "Ps3GhidraScripts";
    src = pkgs.fetchurl {
      url = "https://github.com/clienthax/Ps3GhidraScripts/releases/download/1.069/ghidra_11.0_PUBLIC_20240204_Ps3GhidraScripts.zip";
      hash = "04iqfgz1r1a08r2bdd9nws743a7h9gdxqfdf3dxbx10xqnpnwny8";
    };
    phases = "installPhase";
    installPhase = ''
      mkdir -p $out
      cp -r $src $out
    '';
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
            ps3GhidraScripts
          ]);
      };
    };
  }
