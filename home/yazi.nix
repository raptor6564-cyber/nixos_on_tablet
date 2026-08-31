{ config, lib, pkgs, ... }: {
  programs = {
    yazi = {
      enable = true;
      enableFishIntegration = true;
      # Сам TOML-конфиг, переведенный в синтаксис Nix
      settings = {
        opener = {
          tmux_split_v = [
            {
              run = "${lib.getExe pkgs.tmux} split-window -h \"\$EDITOR \\\"\$@\\\"\"";
              block = true;
              desc = "Open in vertical Tmux pane";
            }
          ];
          tmux_split_h = [
            {
              run = "${lib.getExe pkgs.tmux} split-window -v \"\$EDITOR \\\"\$@\\\"\"";
              block = true;
              desc = "Open in horizontal Tmux pane";
            }
          ];
        };

        open = {
          rules = [
            {
              mime = "text/*"; use = [ "edit" "tmux_split_v" "tmux_split_h" ];
            }
            {
              mime = "application/json"; use = [ "edit" "tmux_split_v" "tmux_split_h" ];
            }
          ];
        };
      };
    };
  };

  xdg.desktopEntries = {
    yazi = {
      name = "Yazi";
      genericName = "Yazi File Manager";
      exec = "yazi %f";
      icon = "${pkgs.yazi}/share/pixmaps/yazi.png";
      terminal = true;
      categories = [ "System" "FileManager" "FileTools" "ConsoleOnly" ];
      mimeType = [ "inode/directory" ];
      type= "Application";
      comment="Blazing fast terminal file manager written in Rust, based on async I/O";
    };
  };
}
