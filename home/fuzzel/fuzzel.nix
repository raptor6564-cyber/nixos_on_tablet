{ config, lib, pkgs, ... }: {
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    # Шрифт и размер — подберите под свой дисплей
    font = JetBrainsMono Nerd Font:size=18

    # dpi-aware = yes

    # image-size-ratio = 0.5

    # Сколько строк показывать
    lines = 10

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
