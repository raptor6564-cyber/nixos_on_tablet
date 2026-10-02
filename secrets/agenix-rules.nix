let
  mytablet = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINh45udLj81NiAX+8c9LsVL3wfTfIMjbCmgxXADVDgcS";
in {
  "rclone-gdrive-token.age".publicKeys = [ mytablet ];
  "rclone-ydisk-token.age".publicKeys = [ mytablet ];
}
