#!/bin/bash -e

# Add SQL script file
install -v -m 755 files/sql_script.sql "${ROOTFS_DIR}/home/sql_script.sql"

# Create database with the previous script
on_chroot <<- EOF
	sqlite3 dataforus.db < /home/sql_script.sql
EOF
