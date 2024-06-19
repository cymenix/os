{
  lib,
  config,
  ...
}: let
  cfg = config.modules;
in
  with lib; {
    imports = [
      ./vps
    ];
    options = {
      modules = {
        operations = {
          enable = mkEnableOption "Enable operations" // {default = cfg.enable;};
        };
      };
    };
  }
