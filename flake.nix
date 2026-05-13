{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    driftwm.url = "github:malbiruk/driftwm";  # Добавьте эту строку

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
        ./network.nix
        # ./mts-cloud_vpn.nix
        ./tmux.nix
        ./fish.nix
        ./nvim.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        ./waybar/waybar.nix

        # Tablet-mode module - упрощенная версия
        ({ config, pkgs, lib, ... }: let
          # Получаем исходники модуля
          tablet-mode-src = pkgs.fetchFromGitHub {
            owner = "aligator";
            repo = "tablet-mode";
            rev = "master";
            # Временно используем fake hash, после первой попытки nix покажет правильный
            sha256 = "sha256-e7etCk8d2uVjLJhmWE5ll8b0NKIO7s9skLFFQpo46g0=";
          };
          
          # Собираем модуль ядра напрямую
          tablet-mode-ko = pkgs.runCommand "tablet-mode-${config.boot.kernelPackages.kernel.modDirVersion}" {
            nativeBuildInputs = [ pkgs.makeWrapper pkgs.gcc pkgs.binutils ];
            buildInputs = [ config.boot.kernelPackages.kernel ];
          } ''
            # Копируем исходники
            cp -r ${tablet-mode-src}/* .
            chmod -R u+w .
            
            # Собираем модуль
            make KERNEL_DIR=${config.boot.kernelPackages.kernel.dev}/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/build
            
            # Устанавливаем
            mkdir -p $out/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/misc
            cp tablet-mode.ko $out/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/misc/
          '';
        in {
          # Конфигурация модуля
          boot.extraModulePackages = [ tablet-mode-ko ];
          boot.kernelModules = [ "tablet-mode" ];
          boot.blacklistedKernelModules = [ "ilitek_ts_i2c" ];
          
          # udev правило для автозагрузки при подключении клавиатуры
          services.udev.extraRules = ''
            ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="258a", ATTR{idProduct}=="0020", RUN{builtin}+="kmod load tablet-mode"
          '';
        })
      ];
    };
  };
}
