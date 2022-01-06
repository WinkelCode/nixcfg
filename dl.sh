#!/bin/sh
mirror=https://raw.githubusercontent.com/martinsstuff/nixcfg/dev/

curl -O ${mirror}nixOSFileystemSetup.sh
curl -O ${mirror}nixOSPartitionSetup.sh

chmod +x nixOSFileystemSetup.sh
chmod +x nixOSPartitionSetup.sh