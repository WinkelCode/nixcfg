#!/bin/sh
mount /dev/${disk}2 /mnt
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@home
umount /mnt