{
  config,
  lib,
  ...
}: let
  cfg = config.modules.operations;
in
  with lib; {
    options = {
      modules = {
        operations = {
          vps = {
            enable = mkEnableOption "Enable support for controlling VPS" // {default = cfg.enable;};
          };
        };
      };
    };
  }
