{ config, lib, pkgs, ... }:
let
  remoteName = "ydisk";
  mountPoint = "${config.home.homeDirectory}/YandexDisk";
in
{
  # 1. Секрет через agenix
  age.secrets = {
    "rclone-ydisk-token" = {
      file = ../secrets/rclone-ydisk-token.age;
    };
  };

  programs.rclone = {
    enable = true;

    remotes.${remoteName} = {
      config = {
        type = "yandex";
        # У Яндекса нет scope как у гугла.
        # client_id / client_secret можно не указывать —
        # rclone использует свои дефолтные.
        # Если хочешь свои (рекомендуется для стабильности):
        # client_id = "...";
        # client_secret = "...";
      };

      secrets = {
        token = config.age.secrets."rclone-ydisk-token".path;
      };

      mounts."" = {
        enable = true;
        autoMount = true;
        mountPoint = mountPoint;

        options = {
          vfs-cache-mode = "writes";
          vfs-cache-max-size = "1G";
          dir-cache-time = "5m";
          daemon-timeout = "30s";
        };
      };
    };
  };

  home.activation.createYdiskMountPoint = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${mountPoint}
  '';
}
