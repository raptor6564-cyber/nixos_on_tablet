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
      ];

      imports = [
        ./fish.nix
        ./nvim.nix
        ./niri/niri.nix
        ./tmux/tmux.nix
        ./waybar/waybar.nix
        ./wvkbd.nix
        ./fuzzel/fuzzel.nix
      ];

      xdg.enable = true;
      xdg.userDirs.enable = true;
      xdg.userDirs.createDirectories = true;
      xdg.desktopEntries = {
        virt-viewer = {
          name = "Virt-Viewer";
          exec = "virt-viewer -c qemu:///system";
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
              exec = "virt-viewer -c qemu:///system";
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

      services.awww.enable = true;
    };

  };
}
