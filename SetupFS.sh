#!/bin/sh

# Partition Variables
efipart=$1
datapart=$2

# Check if Partition Variables Exist
if [ -z $1 ] && [ -z $2 ]; then echo "Error: Missing Partition Arguments (\$1 & \$2)"
    elif [ -z $2 ]; then echo "Error: Missing Data Partition Argument (\$2)"; fi
if [ -z $2 ]; then exit 1; fi

# Ask for Confirmation
echo "Format Partitions with EFI @ \"$efipart\" and BTRFS @ \"$datapart\"?"
read -p "Continue (y/N)?" -n 1 confirm; printf "\n"
if [[ -z "$confirm" || "$confirm" =~ [^Yy] ]]; then echo "Cancelled"; exit 1; fi;

# Normal or TMPFS
layout=none
until [[ $layout =~ [12] ]]; do
    printf "Select Data Partition Layout:\n1. Normal - @, @Library, @home\n2. Root TMPFS - TMPFS Root, @Library, @home\n"
    read -p "Layout Choice? " layout; printf "\n";
    if [ -z $layout ]; then layout=none; fi # Prevent error if layout is empty
done

# Formatting Type
if [ $layout == 1 ]; then layout=normal # Normal Formatting  
    elif [ $layout == 2 ]; then layout=tmpfs; fi # TMPFS Formatting

# Formatting Partitions
mkfs.vfat -F 32 $efipart
mkfs.btrfs -f $datapart

# Mount BTRFS for Subvolume Creation
mount $datapart /mnt

# Create Appropriate Subvolumes
if [ $layout == normal ]; then btrfs subvolume create /mnt/@; fi # Root only with Normal Layout
btrfs subvolume create /mnt/@Library
btrfs subvolume create /mnt/@home

# Unmount BTRFS after Subvolume Creation
umount /mnt

# Remout with Subvolumes - With Root TMPFS if Desired
if [ $layout == tmpfs ]; then mount -t tmpfs tmpfs /mnt
    else mount -o subvol=@ $datapart /mnt; fi

mkdir /mnt/boot; mount $efipart /mnt/boot
mkdir /mnt/home; mount -o subvol=@home $datapart /mnt/home
mkdir /mnt/Library; mount -o subvol=@Library $datapart /mnt/Library

echo done
exit