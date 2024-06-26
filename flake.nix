{
  description = "Nix Flake for 5G system emulation frameworks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      nixosModules.gtp5g = import ./modules/gtp5g;

      packages = forAllSystems
        (system:
          let
            pkgs = nixpkgsFor.${system};
          in
          {
            oai-ran = pkgs.callPackage pkgs/openairinterface5g { };
            srsran5g = pkgs.callPackage pkgs/srsran5g { };
          }
        );
    };
}
