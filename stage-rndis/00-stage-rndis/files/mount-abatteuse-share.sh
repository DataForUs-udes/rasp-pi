#!/bin/bash

MOUNT_POINT="/mnt/abatteuse"
SHARE="//10.0.0.2/abatteuse"
USERNAME="Guest"
PASSWORD=""

# Make sure the mount point exists
mkdir -p $MOUNT_POINT

# Check if we are on xp
if nmap -O 10.0.0.2 | grep -q "XP"; then
    mount -t cifs $SHARE $MOUNT_POINT -o username=$USERNAME,password=$PASSWORD,vers=1.0,uid=$(id -u),gid=$(id -g)
else
    mount -t cifs $SHARE $MOUNT_POINT -o username=$USERNAME,password=$PASSWORD,uid=$(id -u),gid=$(id -g)
fi
