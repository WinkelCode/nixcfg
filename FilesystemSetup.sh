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

echo "Formatting EFI Partition $efipart"
mkfs.vfat -F 32 $efipart
echo "Formatting Data Partition $datapart"
mkfs.btrfs -f $datapart

# Mount BTRFS for Subvolume Creation
echo "Mounting $datapart for Subvolume Creation"
mount $datapart /mnt

# Create Appropriate Subvolumes
if [ $layout == normal ]; then echo "Creating Root Subvolume"; btrfs subvolume create /mnt/@; else echo "Skipping Root Subvolume"; fi
echo "Creating @home Subvolume"
btrfs subvolume create /mnt/@home
echo "Creating @Library Subvolume"
btrfs subvolume create /mnt/@Library
if [ $3 == nix ]; then echo "Creating @nix Subvolume"; btrfs subvolume create /mnt/@nix; fi

# Unmount BTRFS after Subvolume Creation
echo "Unmounting $datapart after Subvolume Creation"
umount /mnt

# Remout with Subvolumes - With Root TMPFS if Desired
if [ $layout == tmpfs ]; then echo "Mounting TMPFS Root"; mount -o size=2G -o mode=755 -t tmpfs tmpfs /mnt
    else echo "Mounting Root Subvolume"; mount -o subvol=@ $datapart /mnt; fi

echo "Mounting Boot Partition"
mkdir /mnt/boot; mount $efipart /mnt/boot
echo "Mounting @home Subvolume"
mkdir /mnt/home; mount -o subvol=@home $datapart /mnt/home
echo "Mounting @Library Subvolume"
mkdir /mnt/Library; mount -o subvol=@Library $datapart /mnt/Library
if [ $3 == nix ]; then echo "Mounting @nix Subvolume"; mkdir /mnt/nix; mount -o subvol=@nix $datapart /mnt/nix; fi

# Creating Bind Mounts if NixOS
if [ $3 == nix ]; then echo "Creating Bind Mounts for nixOS Persistence"
    echo "Creating Destination Folders"
    mkdir -p /mnt/{etc/nixos,var/log}
    echo "Creating Source Folders"
    mkdir -p /mnt/Library/nixOS/{config,log}
    echo "Mounting nixOS Configuration Directory"
    mount -o bind /mnt/Library/nixOS/config /mnt/etc/nixos
    echo "Mounting nixOS Log Directory"
    mount -o bind /mnt/Library/nixOS/log /mnt/var/log
fi    

echo done
exit