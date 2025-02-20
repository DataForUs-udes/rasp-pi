#!/bin/bash

sed -i 's/10\.0\.0\.2/windows-host/g' stage-rndis/00-stage-rndis/files/mount-abatteuse-share.sh

source stage-rndis/00-stage-rndis/files/mount-abatteuse-share.sh

ls -lh /mnt/abatteuse