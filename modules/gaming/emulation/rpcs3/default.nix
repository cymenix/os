{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with pkgs; let
  cfg = config.modules.gaming.emulation;
  ps3bios = stdenv.mkDerivation {
    name = "ps3bios";
    src = fetchzip {
      url = "https://archive.org/download/ps3-official-firmwares/Firmware%204.91/PS3UPDAT.PUP";
      sha256 = "1xw00fns2cvy75czq2z4pz2n45da5db7g98ybmrrdd9nj22bv55w";
    };
    dontBuild = true;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out $out/bios
      cp -r $src/* $out/bios
    '';
  };
in {
  options = {
    modules = {
      gaming = {
        emulation = {
          rpcs3 = {
            enable = mkEnableOption "Enable rpcs3 emulation (PlayStation 3)" // {default = cfg.enable;};
          };
        };
      };
    };
  };
  config = mkIf (cfg.enable && cfg.rpcs3.enable) {
    home-manager = mkIf (config.modules.home-manager.enable) {
      users = {
        ${config.modules.users.user} = {
          home = {
            packages = [rpcs3];
            file = {
              ".config/rpcs3/bios" = {
                source = "${ps3bios}/bios";
              };
            };
          };
        };
      };
    };
  };
}
