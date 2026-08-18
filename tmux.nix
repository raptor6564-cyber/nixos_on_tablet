{ config, lib, pkgs, ... }:
let
  tmuxConf = builtins.readFile ./tmux.conf;
in
{
  home-manager = {
    users.koshchei = { pkgs, ... }: {
      programs = {
        tmux = {
	  enable = true;
	  extraConfig = tmuxConf;
	};
      };
    };
  };
}
