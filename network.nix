{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    networkmanager-l2tp
  ];
  networking.hostName = "mytablet"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager = {
    enable = true;  # Easiest to use and most distros use this by default.
    plugins = with pkgs; [ networkmanager-l2tp networkmanager-strongswan ];
  };
  services.strongswan.enable = true;
  services.xl2tpd.enable = true;
  services.strongswan.secrets = [ "ipsec.d/ipsec.nm-l2tp.secrets" ];
  # services.strongswan.secrets = [
  #   {
  #     name = "ipsec-nm-l2tp";
  #     path = "ipsec.nm-l2tp.secrets";
  #   }
  # ];

  systemd.tmpfiles.rules = [ "L /etc/ipsec.secrets - - - - /etc/ipsec.d/ipsec.nm-l2tp.secrets" ];
  environment.etc."strongswan.conf".text = "";
}
