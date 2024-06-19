{
  config,
  lib,
  ...
}: let
  cfg = config.modules.operations.vps.hcloud.completion;
  hcloudZshCompletion = ".config/hcloud/completion/zsh/_hcloud";
in
  with lib; {
    options = {
      modules = {
        operations = {
          vps = {
            hcloud = {
              completion = {
                zsh = mkEnableOption "Enable hcloud zsh shell completion" // {default = cfg.enable && config.modules.shell.zsh.enable;};
              };
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.zsh.enable && config.modules.shell.zsh.enable) {
      home = {
        file = {
          ${hcloudZshCompletion} = {
            source = ./_hcloud;
          };
        };
      };
      programs = {
        zsh = {
          initExtraBeforeCompInit = ''
            fpath+=(~/${hcloudZshCompletion})
          '';
        };
      };
    };
  }
