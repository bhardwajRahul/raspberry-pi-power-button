#!/bin/bash

wget url
wget url

if [ ! -d "/usr/local/bin" ]; then
    sudo mkdir -p /usr/local/bin
fi

sudo chmod +x power_button.py
sudo mv power_button.py /usr/local/bin
sudo mv power_button.service /etc/systemd/system
sudo systemctl start shutdown_button.service
sudo systemctl enable shutdown_button.service