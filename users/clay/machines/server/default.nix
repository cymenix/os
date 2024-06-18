{user, ...}: {
  config = {
    modules = {
      machine = {
        kind = "server";
      };
      users = {
        inherit user;
      };
    };
    home-manager = {
      users = {
        ${user} = {
          modules = {};
        };
      };
    };
  };
}
