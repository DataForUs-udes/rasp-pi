#!/bin/bash -e

# Add StanForD example files
on_chroot <<- EOF
    mkdir /home/pi/StanForD_Example
    mkdir /home/pi/.ssh   
EOF

install -v -m 666 "files/StanForD-Parser/data/input_files/secteur plat - 2024-07-07 20.20.pri" "${ROOTFS_DIR}/home/pi/StanForD_Example/secteur plat - 2024-07-07 20.20.pri"
install -v -m 666 "files/StanForD-Parser/data/input_files/secteur plat.stm" "${ROOTFS_DIR}/home/pi/StanForD_Example/secteur plat.stm"

# Add git SSH key + config
on_chroot <<- EOF
    echo "${SSH_PRIVATE_KEY}" | base64 -d > "${ROOTFS_DIR}/home/pi/.ssh/id_rsa"
    chmod 600 "${ROOTFS_DIR}/home/pi/.ssh/id_rsa"

    # Configure SSH to use GitHub without strict host checking
    echo "Host github.com
        IdentityFile ~/.ssh/id_rsa
        AddKeysToAgent yes
        StrictHostKeyChecking no" > "${ROOTFS}/home/pi/.ssh/config"

    chmod 600 "${ROOTFS_DIR}/home/pi/.ssh/config"
    chown -R 1000:1000 "${ROOTFS_DIR}home/pi/.ssh"

    eval "$(ssh-agent -s)"
    ssh-add "${ROOTFS_DIR}/home/pi/.ssh/id_rsa"
EOF

# TODO : Add mock classes if necessary