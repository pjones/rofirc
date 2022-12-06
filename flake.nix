{
  description = "Peter's Rofi configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      # List of supported systems:
      supportedSystems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];

      # Function to generate a set based on supported systems:
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Attribute set of nixpkgs for each system:
      nixpkgsFor = forAllSystems (system:
        import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (system: {
        default = self.packages.${system}.rofirc;
        rofirc = import ./. { pkgs = nixpkgsFor.${system}; };
      });

      overlays.default = final: prev: {
        pjones = (prev.pjones or { }) // {
          rofirc = self.packages.${prev.system}.rofirc;
        };
      };

      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system}; in
        {
          default = pkgs.mkShell {
            buildInputs = [ self.packages.${system}.rofirc ];
            inputsFrom = builtins.attrValues self.packages.${system};
          };
        });
    };
}
