#!/bin/bash -e

# create repo of the ble 
on_chroot <<- EOF
    mkdir /home/pi/raspi-ble
    
EOF





#installing files of raspi-ble
install -v -m 755 files/raspi-ble/advertisement.py "${ROOTFS_DIR}/pi/home/raspi-ble/advertisement.py"
install -v -m 755 files/raspi-ble/bletools.py "${ROOTFS_DIR}/pi/home/raspi-ble/bletools.py"
install -v -m 755 files/raspi-ble/ftp_ble.py "${ROOTFS_DIR}/pi/home/raspi-ble/ftp_ble.py"
install -v -m 755 files/raspi-ble/service.py "${ROOTFS_DIR}/pi/home/raspi-ble/service.py"
install -v -m 755 files/raspi-ble/json_test.json "${ROOTFS_DIR}/pi/home/raspi-ble/json_test.json"
install -v -m 655 files/main.conf "${ROOTFS_DIR}/etc/bluetooth/main.conf"


