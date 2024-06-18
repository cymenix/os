{user, ...}: {
  config = {
    modules = {
      machine = {
        kind = "desktop";
      };
      users = {
        inherit user;
      };
      boot = {
        secureboot = {
          enable = true;
        };
      };
      gpu = {
        enable = true;
        amd = {
          enable = true;
        };
      };
      security = {
        sops = {
          enable = true;
        };
      };
      networking = {
        enable = true;
        wireless = {
          enable = true;
          eduroam = {
            enable = true;
          };
        };
      };
      gaming = {
        enable = true;
        steam = {
          enable = true;
        };
      };
      crypto = {
        ledger-live = {
          enable = true;
        };
      };
    };
    home-manager = {
      users = {
        ${user} = {
          modules = {
            editor = {
              nixvim = {
                vimtex = {
                  enable = true;
                };
              };
            };
            security = {
              sops = {
                enable = true;
              };
            };
          };
        };
      };
    };
  };
}
