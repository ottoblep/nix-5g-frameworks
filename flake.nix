{
  description = "Nix Flake for OpenAirInterface";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems
        (system:
          let
            pkgs = nixpkgsFor.${system};
          in
          {
            default = pkgs.callPackage pkgs/openairinterface5g { };
          }
        );
    };
}