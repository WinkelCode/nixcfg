#!/bin/sh
echo "Mounting $disk Partition (TBD) for Subvolume Creation"
mount ${disk}2 /mnt
echo "Creating Subvolume @nix"
btrfs subvolume create /mnt/@nix
echo "Creating Subvolume @home"
btrfs subvolume create /mnt/@home
echo "Unmounting $disk Partition (TBD)"
#umount /mnt