{ config, lib, pkgs, ... }: {
  accounts.email.accounts = {
    "raptor6564@gmail.com" = {
      realName = "Anton Suhavarau";
      primary = true;
      address = "raptor6564@gmail.com";
      userName = "raptor6564@gmail.com";
      flavor = "gmail.com"; # or configure imap/smtp manually
      thunderbird = {
        enable = true;
        settings = id: {
          "mail.server.server_${id}.authMethod" = 10; # 10 enables OAuth2
          "mail.smtpserver.smtp_${id}.authMethod" = 10;
        };
      };
    };
  };

  accounts.calendar.accounts = {
    "raptor6564@gmail.com" = {
      primary = true;

      # Google Calendar патрабуе тып caldav
      remote = {
        type = "caldav";

        # Заменіце USER_EMAIL%40gmail.com на ваш адрас (сімвал @ трэба замяніць на %40)
        url = "https://apidata.googleusercontent.com/caldav/v2/raptor6564%40gmail.com/events";

        userName = "raptor6564@gmail.com";
      };

      # Інтэграцыя з Thunderbird
      thunderbird = {
        enable = true;
        profiles = [ "default" ];
      };
    };
  };
}
