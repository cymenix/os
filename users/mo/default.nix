{
  inputs,
  nixpkgs,
  system,
  user,
  lib,
  ...
}: let
  headlessPkgs = import ../../pkgs/headless.nix {inherit inputs nixpkgs system lib;};
in {
  wsl = import ../../lib/mkMachine.nix {
    inherit inputs nixpkgs system lib user;
    path = ./machines/wsl;
    pkgs = headlessPkgs;
  };
}
