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
  };
}
