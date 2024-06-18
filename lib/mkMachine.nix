{
  inputs,
  nixpkgs,
  system,
  lib,
  pkgs,
  user,
  path,
}:
lib.nixosSystem {
  specialArgs = {inherit inputs nixpkgs system pkgs user;};
  modules = [(path + /hardware-configuration.nix) path ../modules];
}
