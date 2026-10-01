{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, disko, home-manager, agenix, ... }@inputs:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.mytablet = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs nixpkgs-unstable; };
      modules = [
        ./hardware-configuration.nix
        disko.nixosModules.disko
        ./disko-config.nix
        ./configuration.nix
        ./network.nix

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.koshchei.imports = [
              agenix.homeManagerModules.default
              ./home/default.nix
            ];

            # Пробрасываем unstable в home-manager
            extraSpecialArgs = {
              unstable = nixpkgs-unstable.legacyPackages.${system};
            };
          };
        }
      ];
    };
  };
}
