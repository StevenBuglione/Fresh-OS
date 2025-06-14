#!/bin/bash

# Update all packages
apt update && apt upgrade -y

# Install specific packages
PACKAGES=(
  neovim
)

# Install the packages
apt install -y "${PACKAGES[@]}"