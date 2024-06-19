{
  config,
  lib,
  ...
}: let
  cfg = config.modules.operations.vps.hcloud;
in
  with lib; {
    imports = [
      ./zsh
    ];
    options = {
      modules = {
        operations = {
          vps = {
            hcloud = {
              completion = {
                enable = mkEnableOption "Enable hcloud shell completion" // {default = cfg.enable;};
              };
            };
          };
        };
      };
    };
  }
