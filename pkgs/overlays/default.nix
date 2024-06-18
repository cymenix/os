inputs: let
  headlessOverlays = import ./headless inputs;
  guiOverlays = import ./gui inputs;
in
  headlessOverlays ++ guiOverlays
