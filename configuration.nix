# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
      ./disko-config.nix
    ];

  # Передаем аргумент disks в модуль disk-config.nix
  _module.args.disks = [ "/dev/sda" "/dev/sdb" ];  # Укажите ваш диск здесь

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "postgres-master-warsaw"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Отключаем старый сетевой стек
  networking.useDHCP = false;
  networking.useNetworkd = true;
  
  systemd.network = {
    enable = true;
    networks = {
      "10-wan" = {
        matchConfig.Name = "e*";
        networkConfig = {
          DHCP = "no";
          DNS = "192.168.0.111 8.8.8.8 1.1.1.1";
          Domains = "local";
        };
        address = [
          "192.168.0.65/24"
        ];
        # Исправляем deprecated routeConfig
        routes = [
          { 
            Gateway = "192.168.0.3";
            GatewayOnLink = true;
            Destination = "0.0.0.0/0";
          }
        ];
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

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
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    tcpdump
    tmux
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

  # Enable the PostgreSQL.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    settings = {
      listen_addresses = lib.mkForce "*";
      password_encryption = "md5";

      wal_level = "replica";
      hot_standby = "on";
      max_wal_senders = 10;
      full_page_writes = "on";

      shared_buffers = "2048MB";
      work_mem = "32MB";
      hash_mem_multiplier = 1.5;
      random_page_cost  = 1.1;

      datestyle = "iso, dmy";
    };

    initialScript = pkgs.writeText "init-sql-script" ''
      alter user postgres with password 'password';
      select pg_create_physical_replication_slot('replication_slot');

      DO $$
      BEGIN
         IF NOT EXISTS (
            SELECT FROM pg_catalog.pg_roles
            WHERE  rolname = 'replicator') THEN

            CREATE ROLE replicator LOGIN REPLICATION PASSWORD 'password';
         END IF;
      END $$;
    '';

    authentication = ''
    # TYPE  DATABASE        USER            ADDRESS                 METHOD

    # "local" is for Unix domain socket connections only
    local   all             all                                     trust
    # IPv4 local connections:
    host    all             all             127.0.0.1/32            trust
    # IPv6 local connections:
    host    all             all             ::1/128                 trust

    host    all             all             192.168.0.0/24          md5


    # Allow replication connections from localhost, by a user with the
    # replication privilege.
    local   replication     replicator                              trust
    host    replication     replicator      127.0.0.1/32            trust
    host    replication     replicator      ::1/128                 trust

    host    replication     replicator      192.168.0.0/24          md5
    '';

    ensureDatabases = [ "smbusiness" ];

    ensureUsers = [
      {
        name = "replicator";
        ensureClauses.replication = true;
      }
    ];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 5432 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

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
  system.stateVersion = "25.05"; # Did you read the comment?

}

