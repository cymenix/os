{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.development.reversing;
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
