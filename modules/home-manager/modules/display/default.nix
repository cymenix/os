{
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.modules;
in
  with lib; {
    imports = [
      ./bar
      ./compositor
      ./cursor
      ./gtk
      ./imageviewer
      ./launcher
      ./lockscreen
      ./notifications
      ./pdfviewer
      ./qt
      ./screenshots
    ];
    options = {
      modules = {
        display = {
          enable = mkEnableOption "Enable a slick display configuration" // {default = cfg.enable && osConfig.modules.display.enable;};
        };
      };
    };
  }
