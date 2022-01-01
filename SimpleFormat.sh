#!/bin/sh
disk=$1
sgdisk --clear $disk
sgdisk --new 1:0:+512M --typecode=1:ef00 $disk
sgdisk --new 2:0:0 $disk
mkfs.vfat -F 32 ${disk}1
mkfs.btrfs -f ${disk}2
echo Test
