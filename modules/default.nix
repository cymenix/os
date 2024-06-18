{...}: {lib, ...}:
with lib; {
  imports = [
    ./boot
    ./config
    ./cpu
    ./crypto
    ./display
    ./docs
    ./fonts
    ./gaming
    ./gpu
    ./hostname
    ./home-manager
    ./io
    ./locale
    ./machine
    ./networking
    ./performance
    ./security
    ./shell
    ./system
    ./themes
    ./time
    ./users
    ./virtualisation
    ./wsl
    ./xdg
  ];
  options = {
    modules = {
      enable = mkEnableOption "Enable custom modules" // {default = true;};
    };
  };
}
