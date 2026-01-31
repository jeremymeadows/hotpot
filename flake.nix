{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.hotpot = pkgs.callPackage ./hotpot.nix { };
      packages.${system}.ddefault = self.packages.${system}.hotpot;
    };
}