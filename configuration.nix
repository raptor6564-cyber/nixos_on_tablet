# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz;
in
{
  boot.blacklistedKernelModules = [ "ilitek_ts_i2c" ];
  boot.kernelParams = [ "iio.allow_sysfs_buffer=1" ];
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
      ./disko-config.nix
      ./network.nix
      ./mts-cloud_vpn.nix
      (import "${home-manager}/nixos")
      ./tmux.nix
      ./fish.nix
    ];

  hardware.sensor.iio.enable = true;
  services.udev.extraHwdb = ''
sensor:modalias:*
 ACCEL_MOUNT_MATRIX=1, 0, 0; 0, 1, 0; 0, 0, 1
'';

  # Передаем аргумент disks в модуль disk-config.nix
  _module.args.disks = [ "/dev/nvme0n1" ];  # Укажите ваш диск здесь

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.tmpfiles.rules = [ "L /etc/ipsec.secrets - - - - /etc/ipsec.d/ipsec.nm-l2tp.secrets" ];
  environment.etc."strongswan.conf".text = "";

  # Set your time zone.
  time.timeZone = "Europe/Minsk";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "be_BY.UTF-8";
    supportedLocales = [
      "be_BY.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"  # Optional: Russian is also commonly used in Belarus
    ];
  };
  console = {
    font = "cyr-sun16";
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  services.flatpak.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.koshchei = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    # shell = pkgs.zsh;
    packages = with pkgs; [
      nerd-fonts.cousine
      keepassxc
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    users.koshchei = { pkgs, ... }: {
      home = {
        packages = with pkgs; [ atool httpie blink-qt virt-viewer virt-manager ];
        stateVersion = "25.11";
	sessionVariables.EDITOR = "nvim";
      };
      programs = {
        zsh.enable = true;
      };
  
      xdg.enable = true;
      xdg.userDirs.enable = true;
      xdg.userDirs.createDirectories = true;
      xdg.desktopEntries = {
        "blink-qt" = { # Создайте запись для своего приложения
          name = "blink-qt";
          exec = "/home/koshchei/.nix-profile/bin/blink";
          terminal = false;
          type = "Application";
          categories = [ "Utility" ];
          icon = "/home/koshchei/.nix-profile/share/blink/icons/blink.ico";
  	mimeType = [ "message/sip" ];
          # Другие параметры по необходимости
        };
      };
  
      dconf = {
        enable = true;
        settings = {
          "org/gnome/desktop/input-sources" = {
            xkb-options = [ "ctrl:nocaps" ];
          };
          "org/gnome/shell" = {
            # disable-user-extensions = true; # Optionally disable user extensions entirely
            enabled-extensions = [
              # Put UUIDs of extensions that you want to enable here.
              # If the extension you want to enable is packaged in nixpkgs,
              # you can easily get its UUID by accessing its extensionUuid
              # field (look at the following example).
              pkgs.gnomeExtensions.gnome-40-ui-improvements.extensionUuid
  	    pkgs.gnomeExtensions.bing-wallpaper-changer.extensionUuid
  	    # pkgs.gnomeExtensions.gjs-osk.extensionUuid
    
              # Alternatively, you can manually pass UUID as a string.
              # "gnome-ui-tune@axxapy"
              # ...
            ];
          };
    
          # Configure individual extensions
          # "org/gnome/shell/extensions/blur-my-shell" = {
          #   brightness = 0.75;
          #   noise-amount = 0;
          # };
  
          "org/gnome/shell/extensions/bing-wallpaper-changer" = {
            hide = false;
  	  set-background = true;
          };
  
  	# "org/gnome/online-accounts" = {
          #   # Конфигурация Google аккаунта
          #   accounts = {
          #     google = {
          #       # Базовые настройки (без пароля, который должен быть введен вручную)
          #       enable-calendar = true;
          #       enable-contacts = true;
          #       enable-mail = true;
          #       enable-tasks = true;
          #       identity = "ваш-email@gmail.com";
          #       presentation-identity = "Ваше Имя";
          #     };
          #   };
          # };
        };
      };
      # The state version is required and should stay at the version you
      # originally installed.
    };
  };

  nixpkgs = {
    overlays = [
      (final: prev: {
        gnome = prev.gnome.overrideScope (gfinal: gprev: {
          gvfs = prev.gvfs.override {
            googleSupport = true;
  	  gnomeSupport = true;
  	};
        });
      })
    ];
    config.permittedInsecurePackages = [ "libsoup-2.74.3" ];
  };

  programs.firefox.enable = true;
  programs.foot = {
    enable = true;
    theme = "kitty";
    enableZshIntegration = true;
    settings = {
      main.font = "CousineNerdFontMono:size=15";
      scrollback.lines = 10000;
    };
  };
  # programs.zsh.enable = true;

  xdg.terminal-exec.enable = true;
  xdg.terminal-exec.settings = {
    GNOME = [
      "foot.desktop"
    ];
    default = [
      "foot.desktop"
    ];
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim
    git
    htop
    tcpdump
    tmux
    zsh
    oh-my-zsh
    networkmanager-l2tp
    gnomeExtensions.gnome-40-ui-improvements
    gnomeExtensions.bing-wallpaper-changer
    wl-clipboard
    cifs-utils
    waypipe
    dmidecode
    libinput
    pciutils
    usbutils
    (yazi.override {
		_7zz = _7zz-rar;  # Support for RAR extraction
     })
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "7zz"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  services.openssh.settings.PermitRootLogin = "yes";

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

    fileSystems."/mnt/servicedesk" = {
    device = "//192.168.0.17/ServiceDesk";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},file_mode=0750,dir_mode=0750,uid=1000,gid=100,credentials=/etc/cifs-credentials"
      "nofail"     # Продолжать загрузку, даже если монтирование не удалось
      ];
  };

  fileSystems."/mnt/dev" = {
    device = "//192.168.0.17/dev";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},file_mode=0750,dir_mode=0750,uid=1000,gid=100,credentials=/etc/cifs-credentials"
      "nofail"     # Продолжать загрузку, даже если монтирование не удалось
      ];
  };


  fileSystems."/mnt/ftp" = {
    device = "//192.168.0.19/ftp";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},file_mode=0750,dir_mode=0750,uid=1000,gid=100,username=user,password=''"
      "nofail"     # Продолжать загрузку, даже если монтирование не удалось
      ];
  };

  fileSystems."/mnt/mssqlsupport" = {
    device = "//192.168.0.20/f";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},file_mode=0750,dir_mode=0750,uid=1000,gid=100,credentials=/etc/cifs-credentials"
      "nofail"     # Продолжать загрузку, даже если монтирование не удалось
      ];
  };


  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}

