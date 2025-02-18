#!/bin/bash

# Create USB drive image with MBR partition table
mkdir -p /piusb
dd if=/dev/zero of=/piusb/usbdrive.img bs=1M count=512

# Create a partition table and a single FAT32 partition
parted /piusb/usbdrive.img --script mklabel msdos
parted /piusb/usbdrive.img --script mkpart primary fat32 1MiB 100%

# Set up loop device with partitions
losetup -P /dev/loop0 /piusb/usbdrive.img

# Format the partition to FAT32
mkfs.vfat -F 32 /dev/loop0p1

# Mount the partition and add a test file
mkdir -p /mnt/usbdrive
mount /dev/loop0p1 /mnt/usbdrive
cp /etc/rndis.inf /mnt/usbdrive/rndis.inf
umount /mnt/usbdrive

# Detach loop device
losetup -d /dev/loop0

# Configure USB mass storage
echo "options g_multi file=/piusb/usbdrive.img host_addr=11:22:33:44:55:66 dev_addr=aa:bb:cc:dd:ee:ff" > /etc/modprobe.d/g_mass_storage.conf

# Clean up
rm /etc/systemd/system/create-usbdrive.service
systemctl daemon-reload

echo "USB drive image created and ready to use."
