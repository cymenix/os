{
  inputs,
  nixpkgs,
  system,
  lib,
  ...
}: let
  config = import ./config lib;
  overlays = import ./overlays/headless inputs;
in
  import nixpkgs {
    inherit system config overlays;
  }
