# WSL Custom Ubuntu Image

This repository contains the necessary files to build a custom Ubuntu WSL image with pre-installed packages and configurations.

## Prerequisites

- Docker installed and running on your system
- [WSLB](https://github.com/wsl-images/wslb) CLI tool installed
- WSL2 enabled on Windows

## Building the Docker Image

1. Clone this repository:

```bash
git clone https://github.com/wsl-images/custom-ubuntu-example
cd custom-ubuntu-example
```

2. Build the Docker image:

```bash
docker build -t fresh-os:latest .
```

2. Install docker image as WSL instance:

```bash
wslb install fresh-os:latest
```

3. Launch your new WSL distribution:

```bash
wsl -d fresh-os
```

## What to Expect on First Run

On first run, the `wsl-setup` script will:
- Prompt you to create a user account (prefilled with your Windows username)
- Set up proper WSL permissions
- Configure the default user in `/etc/wsl.conf`
- Install the Ubuntu font in Windows (if possible)

## Included Software

This WSL image includes:
- Ubuntu (latest)
- Neovim
- Additional WSL configurations for better Windows integration

## Customization

To customize the image further, modify the following files before building:
- `config/docker/0-install-packages.sh` - Add or remove packages
- `config/docker/1-configure-wsl.sh` - Adjust WSL-specific configurations