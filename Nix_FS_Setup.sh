#!/bin/sh
set -e

echo Nix Filesystem Setup Script Start

if [ -z $1 ]; then printf "Error: Missing Argument(s)\n$1 EFI Part $2 Data Part\n"; fi

mkfs.vfat -F 32 $1

mkfs.btrfs -f $2

mount $2 /mnt

mkdir /mnt/System

btrfs subvolume create /mnt/System/@nixLogs
btrfs subvolume create /mnt/System/@nixConfig
btrfs subvolume create /mnt/System/@nixSystem
btrfs subvolume create /mnt/@home

umount /mnt

mount -o size=2G -o mode=755 -t tmpfs tmpfs /mnt

mkdir /mnt/boot; mount $1 /mnt/boot

mkdir -p /mnt/var/log; mount -o subvol=System/@nixLogs $2 /mnt/var/log
mkdir -p /mnt/etc/nixos; mount -o subvol=System/@nixConfig $2 /mnt/etc/nixos
mkdir /mnt/nix; mount -o subvol=System/@nixSystem $2 /mnt/nix
mkdir /mnt/home; mount -o subvol=System/@home $2 /mnt/home

sync

echo Nix Filesystem Setup Script Done