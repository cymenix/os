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
        ghidra = super.ghidra.overrideAttrs (finalAttrs: previousAttrs: {
          postPatch = ''
            # Set name of release (eg. PUBLIC, DEV, etc.)
            sed -i -e 's/application\.release\.name=.*/application.release.name=${previousAttrs.releaseName}/' Ghidra/application.properties

            # Set build date and git revision
            echo "application.build.date=$(cat SOURCE_DATE_EPOCH)" >> Ghidra/application.properties
            echo "application.build.date.short=$(cat SOURCE_DATE_EPOCH_SHORT)" >> Ghidra/application.properties
            echo "application.revision.ghidra=$(cat COMMIT)" >> Ghidra/application.properties

            # Tells ghidra to use our own protoc binary instead of the prebuilt one.
            cat >>Ghidra/Debug/Debugger-gadp/build.gradle <<HERE
            protobuf {
              protoc {
                path = '${super.protobuf}/bin/protoc'
              }
            }
            HERE
            sed -i '/<\/unaffected>/i \        <register name="r2"/>' Ghidra/Processors/PowerPC/data/languages/ppc_64_32.cspec
          '';
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
