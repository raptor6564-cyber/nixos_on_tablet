let
  mytablet = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE2dg4nWLr5f0D6Hsqkv3bEfHTS1aBd33QWWZ41fFthZ";
in {
  "rclone-gdrive-token.age".publicKeys = [ mytablet ];
#"rclone-gdrive-client-id.age".publicKeys = [ mytablet ];
#"rclone-gdrive-client-secret.age".publicKeys = [ mytablet ];
}
