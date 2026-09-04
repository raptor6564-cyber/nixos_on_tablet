{ config, lib, pkgs, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    users.koshchei = { pkgs, ... }: {
      home.stateVersion = "26.05";
      home.sessionVariables = {
        PGUSER = "postgres";
        # PGHOST = "";
      };

      home.packages = with pkgs; [
        # (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        fuzzel
        wvkbd
        atool
        httpie
        blink-qt
        virt-viewer
        virt-manager
        pavucontrol
        rustdesk
        drawing
        keepassxc
        handy
      ];

      # .pgpass
      home.activation.createPgpass = ''
        install -m 0600 /dev/null ~/.pgpass

        cat > ~/.pgpass << 'PGPASS_EOF'
        192.168.0.169:*:*:*:3AzlmH0ckNoI
        192.168.0.170:*:*:*:3AzlmH0ckNoI
        192.168.0.141:*:*:*:56*2b1TvYal%z
        *:*:*:*:password
        PGPASS_EOF

        chmod 0600 ~/.pgpass
      '';

      imports = [
        ./fish.nix
        ./nvim.nix
        ./niri/niri.nix
        ./tmux/tmux.nix
        ./waybar/waybar.nix
        ./wvkbd.nix
        ./fuzzel/fuzzel.nix
        ./yazi.nix
      ];

      xdg = {
        enable = true;
        userDirs.enable = true;
        userDirs.createDirectories = true;
        desktopEntries = {
          virt-viewer = {
            name = "Virt-Viewer";
            exec = "virt-viewer -c qemu+ssh://koshchei@192.168.0.133/system";
            type = "Application";
            terminal = false;
            mimeType = [
              "x-scheme-handler/spice"
              "x-scheme-handler/spice+unix"
              "x-scheme-handler/spice+tls"
              "application/x-virt-viewer"
            ];
            startupNotify = true;
            categories = [
              "GNOME"
              "GTK"
              "Network"
              "RemoteAccess"
            ];
            icon = "virt-viewer";
            actions = {
              "new-window" = {
                exec = "virt-viewer -c qemu+ssh://koshchei@192.168.0.133/system";
                name = "New Window";
              };
            };
          };

          "blink-qt" = { # Создайте запись для своего приложения
            name = "blink-qt";
            exec = "${pkgs.blink-qt}/bin/blink";
            terminal = false;
            type = "Application";
            categories = [ "Utility" ];
            icon = "${pkgs.blink-qt}/share/blink/icons/blink.png";
            mimeType = [ "message/sip" ];
            # Другие параметры по необходимости
          };
        };
      };

      services.awww.enable = true;

      programs = {
        thunderbird.enable = true;

        dbeaver = {
          enable = true;
          dataSourcesSettings = {
            connections = {
              postgresql-support = {
                configuration = {
                  database = "postgres";
                  host = "192.168.0.169";
                  port = "5432";
                  auth-model = "postgres_pgpass";
                  user = "postgres";
                  provider-properties = {
                    "@dbeaver-show-non-default-db@" = true;
                  };
                };
                driver = "postgres-jdbc";
                name = "PostgreSQL Support";
                provider = "postgresql";
                save-password = true;
                show-system-objects = true;
              };
            };
            folders = { };
          };
        };
      };

    };

  };
}
