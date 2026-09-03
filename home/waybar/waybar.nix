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

    # Скрипт управления окнами
  xdg.configFile."waybar/window-actions.sh" = {
    executable = true;
    text = ''
      #!/bin/sh

      # Пытаемся убить уже запущенный экземпляр меню
      if ${pkgs.procps}/bin/pkill -f "${pkgs.fuzzel}/bin/fuzzel.*--dmenu.*--prompt.*Окно:"; then
        # Если процесс был найден и убит — выходим (меню закрылось)
        exit 0
      fi

      # Если процесс не запущен — показываем меню
      choice=$(printf "✕ Закрыть окно\n⛶ Полноэкранный режим\n🗗 Плавающий режим\n💀 Убить процесс" | \
          ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Окно: " --width 30 --lines 4)

      case "$choice" in
        *"Закрыть окно")
          ${pkgs.niri}/bin/niri msg action close-window
          ;;
        *"Полноэкранный режим")
          ${pkgs.niri}/bin/niri msg action fullscreen-window
          ;;
        *"Плавающий режим")
          ${pkgs.niri}/bin/niri msg action toggle-window-floating
          ;;
        *"Убить процесс")
          pid=$(${pkgs.niri}/bin/niri msg windows | ${pkgs.jq}/bin/jq -r '.windows[] | select(.is_focused) | .pid')
          [ -n "$pid" ] && kill -9 "$pid"
          ;;
      esac
    '';
  };
}
