#!/bin/bash
echo "Starting WSL Configuration"

echo "Configuring WSL Configuration"
cp /tmp/config/wsl/wsl.conf /etc/wsl.conf
chmod 0644 /etc/wsl.conf

echo "Configuring WSL Distribution Configuration"
cp /tmp/config/wsl/wsl-distribution.conf /etc/wsl-distribution.conf
chmod 0644 /etc/wsl-distribution.conf

echo "Configuring WSL Out Of The Box Experience"
mkdir -p /usr/lib/wsl && cp /tmp/config/wsl/wsl-setup /usr/lib/wsl/wsl-setup && chmod 0755 /usr/lib/wsl/wsl-setup

echo "Configuring WSL Windows Terminal Icon"
mkdir -p /usr/share/wsl && cp /tmp/config/wsl/terminal-icon/fresh-os.ico /usr/share/wsl/fresh-os.ico

echo "Configuring WSL Windows Terminal Profile"
mkdir -p /usr/share/wsl && cp /tmp/config/wsl/terminal-profile.json /usr/share/wsl/terminal-profile.json
