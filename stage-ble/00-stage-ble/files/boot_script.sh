#!/bin/bash

# Enable bluetooth chip
sudo rfkill unblock bluetooth
sudo hciconfig hci0 up