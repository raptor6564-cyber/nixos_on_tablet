{ config, lib, pkgs, ... }: {
  systemd.user.services.wvkbd = {
    Unit = {
      Description = "Wayland Virtual Keyboard";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      # Флаг -L задает высоту клавиатуры в пикселях.
      # Вы также можете добавить флаги для кастомизации цветов (например, -bg, -fg, -text)
      ExecStart = "${pkgs.wvkbd}/bin/wvkbd-mobintl -R 8 -l full,cyrillic --landscape-layers full,cyrillic --hidden -L 300";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
