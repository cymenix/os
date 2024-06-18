{
  config,
  lib,
  ...
}: let
  cfg = config.modules;
in
  with lib; {
    imports = [
      ./printing
      ./sound
      ./udisks
      ./xremap
    ];
    options = {
      modules = {
        io = {
          enable = mkEnableOption "Enable IO" // {default = cfg.display.gui != "headless";};
        };
      };
    };
  }
