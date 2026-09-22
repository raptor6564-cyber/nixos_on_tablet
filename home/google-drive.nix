{ config, lib, pkgs, ... }:

let
  remoteName = "gdrive";
  mountPoint = "${config.home.homeDirectory}/GoogleDrive";
in
{
  # 1. Секреты через agenix (на уровне home-manager)
  # Убедитесь, что пути к файлам .age верные относительно этого файла
  age.secrets = {
    "rclone-gdrive-token" = {
      file = ../secrets/rclone-gdrive-token.age;
    };
  };

  programs.rclone = {
    enable = true;
    
    # УДАЛЕНО: requiresUnit. Home-manager автоматически настроит 
    # зависимость от agenix, если видит age.secrets в этой же конфигурации.
    
    remotes.${remoteName} = {
      config = {
        type = "drive";
        scope = "drive";
      };
      
      # Ссылки на расшифрованные секреты
      secrets = {
        token = config.age.secrets."rclone-gdrive-token".path;
      };
      
      mounts."" = {
        enable = true;
        autoMount = true;
        mountPoint = mountPoint;
        
        options = {
          vfs-cache-mode = "writes";
          allow-other = true; # <-- ВРЕМЕННО ЗАКОММЕНТИРОВАНО для диагностики
          daemon-timeout = "30s";
          # log-level = "DEBUG"; # Включаем DEBUG, чтобы увидеть реальную причину сбоя в логах
        };
      };
    };
  };
  
  home.activation.createMountPoint = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${mountPoint}
  '';
}
