{ config, lib, pkgs, ... }: {
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    # Шрифт и размер — подберите под свой дисплей
    font = JetBrainsMono Nerd Font 18
    dpi-aware = yes

    # Сколько строк показывать
    lines = 8

    # Ширина в символах
    width = 45

    # Отступы, чтобы строки было удобно тапать
    horizontal-pad = 24
    vertical-pad = 16
    inner-pad = 12

    # Высота строки задаётся через line-height
    line-height = 44

    # Запускать по центру экрана
    anchor = center

    exit-on-keyboard-focus-loss = yes

    [colors]
    background = 1e1e2eee
    text = cdd6f4ff
    match = f38ba8ff
    selection = 45475aff
    selection-text = cdd6f4ff
    border = f38ba8ff

    [border]
    width = 2
    radius = 12
  '';
}
