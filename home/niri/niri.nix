{ config, lib, pkgs, ... }: {
  # Помещает файл в ~/.config/niri/config.kdl
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
}
