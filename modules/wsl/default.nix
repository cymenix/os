{
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules;
in {
  imports = [inputs.wsl.nixosModules.default];
  options = {
    modules = {
      wsl = {
        enable = mkEnableOption "Enable WSL support" // {default = cfg.machine.kind == "wsl";};
      };
    };
  };
  config = mkIf (cfg.enable && cfg.wsl.enable) {
    wsl = {
      enable = true;
      defaultUser = cfg.users.user;
      interop = {
        includePath = true;
        register = true;
      };
      nativeSystemd = true;
      startMenuLaunchers = true;
      usbip = {
        enable = true;
        autoAttach = [];
      };
      useWindowsDriver = true;
      wslConf = {
        automount = {
          enabled = true;
          mountFsTab = false;
          options = "metadata,uid=1000,gid=100";
          root = "/mnt";
        };
        interop = {
          enabled = true;
          appendWindowsPath = false;
        };
        network = {
          generateHosts = true;
          generateResolvConf = true;
          hostname = config.networking.hostName;
        };
        user = {
          default = cfg.users.user;
        };
      };
    };
  };
}
