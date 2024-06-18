{user, ...}: {
  config = {
    modules = {
      machine = {
        kind = "laptop";
      };
      users = {
        inherit user;
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
      security = {
        sops = {
          enable = true;
        };
      };
    };
    home-manager = {
      users = {
        ${user} = {
          modules = {
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
