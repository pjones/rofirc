{
  description = "Peter's Rofi configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      # List of supported systems:
      supportedSystems = nixpkgs.lib.platforms.linux;

      # Function to generate a set based on supported systems:
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Attribute set of nixpkgs for each system:
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (system: {
        rofirc = import ./. { pkgs = nixpkgsFor.${system}; };
      });

      defaultPackage =
        forAllSystems (system: self.packages.${system}.rofirc);

      overlay = final: prev: {
        pjones = (prev.pjones or { }) //
          { rofirc = self.packages.${prev.system}.rofirc; };
      };

      devShell = forAllSystems (system:
        let pkgs = nixpkgsFor.${system}; in
        pkgs.mkShell {
          REAL_ROFI = "${pkgs.rofi}/bin/rofi";
          inputsFrom = builtins.attrValues self.packages.${system};
        });
    };
}
