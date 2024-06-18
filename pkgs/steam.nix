{
  inputs,
  nixpkgs,
  system,
  lib,
  ...
}: let
  config = import ./config/steam lib;
  overlays = import ./overlays inputs;
in
  import nixpkgs {
    inherit system config overlays;
  }
