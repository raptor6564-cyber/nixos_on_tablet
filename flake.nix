{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    driftwm.url = "github:malbiruk/driftwm";
  };

  outputs = { self, nixpkgs, disko, home-manager, ... }@inputs:
  {
    nixosConfigurations.mytablet = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware-configuration.nix
        disko.nixosModules.disko
        ./disko-config.nix
        ./configuration.nix
        # ./network.nix
        ./tmux.nix
        ./fish.nix
        ./nvim.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        ./waybar/waybar.nix

      ];
    };
  };
}
