#!/bin/sh
git fetch --all
git reset --hard
git pull
chmod +x *.sh
#nixos-rebuild switch