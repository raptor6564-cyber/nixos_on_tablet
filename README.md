I build nixos-configuration for my "chuwi hi max" table here.

# Quickstart
``` bash
cd /tmp
git clone git@github.com:raptor6564-cyber/nixos_on_tablet.git # OR https://github.com/raptor6564-cyber/nixos_on_tablet.git
cd nixos_on_tablet
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --yes-wipe-all-disks --arg disks '[ "/dev/nvme0n1" ]' disko-config.nix
sudo nixos-generate-config --no-filesystems --root /mnt
sudo cp ./* /mnt/etc/nixos/
sudo nixos-install
```
