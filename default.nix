{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenvNoCC.mkDerivation {
  name = "pjones-rofirc";
  src = ./.;
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
  installPhase = ''
    mkdir -p $out/bin $out/etc $out/themes

    for file in bin/*; do
      install -m 0550 "$file" $out/bin
    done

    for file in themes/*; do
      install -m 0440 "$file" $out/themes
    done

    install -m 0440 etc/config.rasi $out/etc
  '';
}
