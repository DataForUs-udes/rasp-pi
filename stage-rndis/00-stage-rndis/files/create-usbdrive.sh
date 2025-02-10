#!/bin/bash

# Create USB drive image
mkdir -p /piusb
dd if=/dev/zero of=/piusb/usbdrive.img bs=1M count=512
mkfs.vfat -F 32 /piusb/usbdrive.img

# Add a file to the USB drive image
mkdir -p /mnt/usbdrive
mount -o loop /piusb/usbdrive.img /mnt/usbdrive
echo "Hello World!" > /mnt/usbdrive/hello.txt
umount /mnt/usbdrive

# Configure USB mass storage
echo "options g_multi file=/piusb/usbdrive.img host_addr=11:22:33:44:55:66 dev_addr=aa:bb:cc:dd:ee:ff" > /etc/modprobe.d/g_mass_storage.conf

# Clean up
rm /etc/systemd/system/create-usbdrive.service
systemctl daemon-reload