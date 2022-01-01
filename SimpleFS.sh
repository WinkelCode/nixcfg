#!/bin/sh
echo "Formatting EFI Partition"
mkfs.vfat -F 32 ${disk}1
echo "Formatting Data Partition"
mkfs.btrfs -f ${disk}2
echo "Mounting $disk Partition (TBD) for Subvolume Creation"
mount ${disk}2 /mnt
echo "Creating Subvolume @nix"
btrfs subvolume create /mnt/@nix
echo "Creating Subvolume @home"
btrfs subvolume create /mnt/@home
echo "Unmounting $disk Partition (TBD)"
umount /mnt