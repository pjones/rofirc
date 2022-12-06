{ pkgs ? import <nixpkgs> { }
}:
let
  lib = pkgs.lib;

  deps = with pkgs; [
    bash
    coreutils
    rofi
  ];

  path = lib.makeBinPath deps;
in
pkgs.stdenvNoCC.mkDerivation {
  name = "pjones-rofirc";
  src = ./.;
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
  buildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/wrapped $out/bin $out/etc $out/themes

    for file in bin/* wrapper/*; do
      name=$(basename "$file")
      install -m 0550 "$file" "$out/wrapped"
      substituteAllInPlace "$out/wrapped/$name"

      makeWrapper "$out/wrapped/$name" "$out/bin/$name" \
        --prefix PATH : "${path}"
    done

    for file in themes/*; do
      install -m 0440 "$file" "$out/themes"
      substituteAllInPlace "$out/themes/$(basename "$file")"
    done

    install -m 0440 etc/config.rasi "$out/etc"
  '';
}
