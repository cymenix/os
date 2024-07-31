{
  pkgs ?
    import <nixpkgs> {
      overlays = [
        (final: prev: {
          ffado = prev.ffado.overrideAttrs (oldAttrs: {
            src = prev.fetchurl {
              inherit (oldAttrs.src) url;
              hash = "sha256-0iFXYyGctOoHCdc232Ud80/wV81tiS7ItiS0uLKyq2Y=";
            };
          });
        })
      ];
    },
}: let
  qemu-anti-detection =
    (pkgs.qemu.override {
      hostCpuOnly = true;
    })
    .overrideAttrs (finalAttrs: previousAttrs: {
      # ref: https://github.com/zhaodice/qemu-anti-detection
      patches =
        (previousAttrs.patches or [])
        ++ [
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/zhaodice/qemu-anti-detection/main/qemu-8.2.0.patch";
            sha256 = "0apkgnw4khlskq9kckx84np1qd6v3yblddyhf3hf1f1apxwpy8fc";
          })
        ];
      postFixup =
        (previousAttrs.postFixup or "")
        + "\n"
        + ''
          for i in $(find $out/bin -type f -executable); do
            mv $i "$i-anti-detection"
          done
        '';
      pname = "qemu-anti-detection";
    });
in
  qemu-anti-detection
