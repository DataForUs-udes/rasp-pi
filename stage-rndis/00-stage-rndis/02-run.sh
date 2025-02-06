#!/bin/bash -e

# Config Gadget mode
on_chroot <<- EOF
    echo "dtoverlay=dwc2" >> /boot/firmware/config.txt
    sed -i 's/$/ modules-load=dwc2,g_ether,g_mass_storage/' /boot/firmware/cmdline.txt
EOF

# Config dnsmasq DHCP
on_chroot <<- EOF
    echo "interface=usb0" > /etc/dnsmasq.conf
    echo "dhcp-range=10.0.0.2,10.0.0.2,12h" >> /etc/dnsmasq.conf
    echo "dhcp-option=3,10.0.0.1" >> /etc/dnsmasq.conf
    echo "dhcp-option=6,10.0.0.1" >> /etc/dnsmasq.conf
EOF

# Static IP for the PI
on_chroot <<- EOF
    echo "auto usb0" >> /etc/network/interfaces
    echo "iface usb0 inet static" >> /etc/network/interfaces
    echo "    address 10.0.0.1" >> /etc/network/interfaces
    echo "    netmask 255.255.255.0" >> /etc/network/interfaces
EOF

# Apply changes to dnsmasq
on_chroot <<- EOF
    systemctl restart dnsmasq
EOF

# DHCP lease clearer script
install -v -m 755 files/clear-dhcp-leases.sh "${ROOTFS_DIR}/etc/clear-dhcp-leases.sh"
install -v -m 755 files/clear-dhcp-leases.service "${ROOTFS_DIR}/etc/systemd/system/clear-dhcp-leases.service"

on_chroot <<- EOF
    systemctl daemon-reload
    systemctl enable clear-dhcp-leases.service
    systemctl start clear-dhcp-leases.service
EOF

# Configure USB mass storage
on_chroot <<- EOF
    mkdir -p /piusb
    dd if=/dev/zero of=/piusb/usbdrive.img bs=1M count=32
    mkfs.vfat /piusb/usbdrive.img
    echo "options g_mass_storage file=/piusb/usbdrive.img stall=0 removable=1" > /etc/modprobe.d/g_mass_storage.conf
EOF

# Install the first boot script
install -v -m 755 files/create-usbdrive.sh "${ROOTFS_DIR}/usr/local/bin/create-usbdrive.sh"
install -v -m 644 files/create-usbdrive.service "${ROOTFS_DIR}/etc/systemd/system/create-usbdrive.service"

on_chroot <<- EOF
    systemctl daemon-reload
    systemctl enable create-usbdrive.service
EOF