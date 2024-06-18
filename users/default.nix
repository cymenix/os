{
  inputs,
  nixpkgs,
  system,
  lib,
  ...
}: let
  mkUser = user: import ./${user} {inherit inputs nixpkgs system user lib;};
in {
  clay = mkUser "clay";
  mo = mkUser "mo";
}
