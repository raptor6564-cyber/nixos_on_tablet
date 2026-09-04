{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, home-manager, ... }@inputs: {
    overlays.default = final: prev: {
      handy = final.callPackage ./packages/handy { };
    };

    nixosConfigurations.mytablet = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware-configuration.nix
        { nixpkgs.overlays = [ self.overlays.default ]; }
        disko.nixosModules.disko
        ./disko-config.nix
        ./configuration.nix
        ./network.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        ./home/default.nix
      ];
    };
  };
}
