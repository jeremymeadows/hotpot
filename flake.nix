{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.hotpot = pkgs.callPackage ./package.nix { };
      packages.${system}.default = self.packages.${system}.hotpot;
    };
}