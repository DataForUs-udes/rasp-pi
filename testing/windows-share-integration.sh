#!/bin/bash

sed -i 's/10\.0\.0\.2/host.docker.internal/g' /rasp-pi/stage-rndis/00-stage-rndis/files/mount-abatteuse-share.sh

source /rasp-pi/stage-rndis/00-stage-rndis/files/mount-abatteuse-share.sh

ls -lh /mnt/abatteuse