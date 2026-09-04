{ lib, appimageTools, fetchurl }:
let
  pname = "handy";
  version = "0.9.6"; # версия, которую вы хотите закрепить

  src = fetchurl {
    url = "https://github.com/cjpais/Handy/releases/download/v${version}/Handy_${version}_amd64.AppImage";
    hash = "sha256-xlL2lXLMhGMC12B2GYoHtNYrX3tUgoWTNSdYSjxi9P0=";
  };
  
  appImageContent = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  # AppImage носит почти всё с собой, но часть библиотек Tauri/cpal
  # дёргает через dlopen по имени — в NixOS их в стандартных путях нет.
  # Добавляем их в окружение обёртки:
  extraPkgs = pkgs: with pkgs; [
    alsa-lib                  # захват микрофона (libasound.so.2)
    pipewire                  # звук через PipeWire
    libayatana-appindicator   # иконка в трее
    glib-networking           # TLS для загрузки моделей распознавания

        # Базовые GTK компоненты (AppImage содержит libgtk-3.so, но нужны schemas и loaders)
    gtk3
    gsettings-desktop-schemas
    
    # Wayland компоненты
    wayland
    libxkbcommon
    
    # D-Bus для GTK
    dbus
    
    # WebKitGTK (Tauri использует для UI)
    webkitgtk_4_1
    
    # GDK-Pixbuf loaders (для загрузки иконок)
    gdk-pixbuf
    gtk-layer-shell
    gtk4-layer-shell
    fuse2
    vulkan-tools
    glib

    # Добавляем базовые утилиты, которые скрипты AppImage ожидают найти в /usr/bin
    coreutils
    gnugrep
    util-linux

    libc
  ];

  # Переменные окружения на старте — раскомментируйте, если понадобятся
  # profile = ''
  #   export WEBKIT_DISABLE_DMABUF_RENDERER=1  # артефакты рендера на Wayland
  # '';

  # Полная настройка окружения для GTK в Wayland
  profile = ''
    # Указываем GTK где искать данные AppImage
    export XDG_DATA_DIRS="${appImageContent}/usr/share:$XDG_DATA_DIRS"
    
    # GIO modules (для TLS и других подсистем)
    export GIO_MODULE_DIR="${appImageContent}/usr/lib/x86_64-linux-gnu/gio/modules"
    
    # GDK-Pixbuf loaders (для загрузки иконок и изображений)
    export GDK_PIXBUF_MODULE_FILE="${appImageContent}/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache"
    export GDK_PIXBUF_MODULE_DIR="${appImageContent}/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders"
    
    # GTK input modules
    export GTK_PATH="${appImageContent}/usr/lib/x86_64-linux-gnu/gtk-3.0"
    export GTK_IM_MODULE_FILE="${appImageContent}/usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache"
    
    # Пусть GTK сам выберет backend (wayland или x11 через XWayland)
    # Если хотите принудительно Wayland: export GDK_BACKEND=wayland
    # Если хотите принудительно X11: export GDK_BACKEND=x11
    export GDK_BACKEND=wayland
    
    # WebKit настройки для Tauri
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
    
    # Указываем тип сессии
    export XDG_SESSION_TYPE=wayland

    # Принудительно указываем, где брать gsettings, если скрипт ищет его жестко
    # export PATH="\$\{pkgs.glib.bin}/bin:$PATH"
  '';

  meta = {
    description = "Offline speech-to-text transcription";
    homepage = "https://handy.computer";
    mainProgram = "handy";
  };

  extraInstallCommands = ''
    # Создаём директории
    mkdir -p $out/share/applications/
    mkdir -p $out/share/icons/hicolor/
    
    # Копируем .desktop файл
    install -m 444 -D ${appImageContent}/Handy.desktop \
      $out/share/applications/Handy.desktop
    
    # Копируем все иконки (структура уже правильная: 128x128, 256x256, etc.)
    cp -r ${appImageContent}/usr/share/icons/hicolor/* $out/share/icons/hicolor/
    
    # Исправляем Exec= в .desktop, чтобы указывал на нашу обёртку, а не на внутренний путь
    sed -i "s|^Exec=.*|Exec=handy|g" $out/share/applications/Handy.desktop
    
    # Убираем строку TryExec, если есть (она может указывать на несуществующий путь)
    sed -i "/^TryExec=/d" $out/share/applications/Handy.desktop
  '';
}
