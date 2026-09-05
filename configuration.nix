# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # boot.blacklistedKernelModules = [ "ilitek_ts_i2c" ];
  boot.kernelParams = [ "iio.allow_sysfs_buffer=1" ];

  hardware.sensor.iio.enable = true;

  services.iio-niri = {
    enable = true;
  };

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

  # --- Bluetooth ---
  hardware.bluetooth = {
    enable = true;        # Включает демон bluez
    powerOnBoot = false;   # Включать модуль при загрузке

  # Автоподключение ранее сопряжённых устройств
    settings = {
      General = {
        AutoEnable = false;
        FastConnectable = true;
      };
    };
  };

  # --- Звук через PipeWire ---
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;   # Для 32-битных приложений, если нужны
    pulse.enable = true;        # Совместимость с PulseAudio-приложениями
    wireplumber.enable = true;  # Менеджер сессий (обязателен для PipeWire)
  };

  # Приоритеты реального времени для аудио (рекомендуется)
  security.rtkit.enable = true;

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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # services.flatpak.enable = true;
  # xdg.portal.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.koshchei = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "wireshark" ]; # Enable ‘sudo’ for the user.
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
    config = {
      permittedInsecurePackages = [ "libsoup-2.74.3" ];
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "7zz"
        "uasm"
        "anydesk"
        "libsciter"
        "obsidian"
      ];
    };
  };

  programs = {
    firefox.enable = true;

    wireshark = {
      enable = true;
      dumpcap.enable = true;
      package = pkgs.wireshark;
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.cousine
  ];

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
    git
    htop
    tcpdump
    tmux
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
    # nerd-fonts.cousine
    # sfwbar
    wev
    brightnessctl
    remmina
    telegram-desktop

    fishPlugins.autopair
    fishPlugins.done
    fishPlugins.z

    blueman        # GUI-апплет для управления устройствами
    xxd
    anydesk
  ];

  environment.variables.EDITOR = "nvim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  programs = {
    niri.enable = true;

    fish = {
      enable = true;
      shellInit = ''
        fish_vi_key_bindings
      '';
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
    };

    bash = {
      interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };

    virt-manager.enable = true;

    nautilus-open-any-terminal = {
      enable = true;
      terminal = "foot";
    };

    foot = {
      enable = true;
      theme = "kitty";
      enableFishIntegration = true;
      settings = {
        main = {
          font = "CousineNerdFontMono:size=14";
        };
        scrollback = {
          lines = 10000;
        };
      };
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  services.openssh.settings.PermitRootLogin = "yes";

  services.displayManager.gdm.enable = true;
  # services.desktopManager.gnome.enable = true;

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

