{ config, lib, pkgs, ... }:
let
  waybarConfig = builtins.readFile ./config.jsonc;
in
{
  programs.waybar = {
    enable = true;

    settings.main = builtins.fromJSON waybarConfig;

  # The state version is required and should stay at the version you
  # originally installed.
    style = ''
      @import url("file://${pkgs.waybar}/etc/xdg/waybar/style.css");

      #custom-launcher {
        background-color: #228B22;
      }
      #custom-keyboard {
        background-color: #800000;
      }
      #custom-power {
        background-color: #800000;
      }
      #backlight-slider trough {
        min-width: 100px;
      }
    '';
  };

  xdg.configFile."waybar/power_menu.xml".source = ./power_menu.xml;
}
