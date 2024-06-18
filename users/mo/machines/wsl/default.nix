{
  config,
  user,
  ...
}: {
  config = {
    modules = {
      machine = {
        kind = "wsl";
      };
      users = {
        name = user;
        user = "nixos";
      };
    };
    home-manager = {
      users = {
        ${config.modules.users.user} = {
          modules = {};
        };
      };
    };
  };
}
