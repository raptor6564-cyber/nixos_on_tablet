{ config, lib, pkgs, ... }:
{
  networking.wireguard.enable = true;
  networking.wireguard.interfaces = {
    wg0 = {
      mtu = 1280;
      ips = [
        "10.0.0.2/24"
      ];
      privateKey = "6MC9jYMrVxwGNH6bvkp9CZJ7uO1JXMPiL4P81FeQGnc=";

      peers = [
        {
          allowedIPs = [
            "10.0.0.0/24"
            "192.168.1.0/24"
	     "172.21.7.0/24"
          ];
          endpoint = "93.125.123.85:51820";
          publicKey = "uJMsq8ISHxditKNndBfqlFhVCIHAvxqplRpml3RMnio=";
	  presharedKey = "gUww1dBFSJjcoXu0IlZ/XTH4z+TFAMqrjmn2b/tePiw=";
        }
      ];
    };
  };
}
