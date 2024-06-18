lib: {
  allowUnfree = false;
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [];
}
