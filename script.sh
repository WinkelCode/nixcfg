#!/bin/sh
disk=$1
partsize=$2
sgdisk --clear $disk
sgdisk --new 1:0:+512M --typecode=1:ef00 $disk
sgdisk --new 2:0:+${partsize} $disk
mkfs.vfat -F 32 ${disk}1
mkfs.btrfs -f ${disk}2
mount /dev/sda2 /mnt
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@home
umount /mnt
echo Test
