{
  config,
  lib,
  ...
}: let
  cfg = config.modules.display;
in
  with lib; {
    imports = [
      ./tigervnc
    ];
    options = {
      modules = {
        display = {
          vnc = {
            enable = mkEnableOption "Enable VNC" // {default = cfg.enable;};
            defaultVNC = mkOption {
              type = types.enum ["tigervnc"];
              default = "tigervnc";
            };
          };
        };
      };
    };
  }
