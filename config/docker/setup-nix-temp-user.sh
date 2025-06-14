#!/usr/bin/env bash
set -euo pipefail

#—— Configurable via Dockerfile ARG/ENV ——
: "${NIX_USER:=nixbuild}"
: "${NIX_UID:=1000}"
: "${NIX_GID:=1000}"
: "${NIX_PASSWORD:=}"    # leave empty to lock the account
: "${NIX_INSTALL_COMMAND:=curl -fsSL https://install.determinate.systems/nix | sh -s -- install linux --determinate --init none --no-confirm}"

echo "▶ Creating temporary Nix user '$NIX_USER' (UID=${NIX_UID}, GID=${NIX_GID})…"

# 1) Create group if missing
if ! getent group "$NIX_GID" >/dev/null; then
  groupadd --gid "$NIX_GID" "$NIX_USER"
fi

# 2) Create user if missing
if ! id "$NIX_USER" &>/dev/null; then
  useradd \
    --uid "$NIX_UID" \
    --gid "$NIX_GID" \
    --shell /bin/bash \
    --create-home \
    "$NIX_USER"
fi

# 3) Set or lock password
if [[ -n "$NIX_PASSWORD" ]]; then
  echo "$NIX_USER:$NIX_PASSWORD" | chpasswd
else
  passwd -l "$NIX_USER" >/dev/null 2>&1 || true
fi

# 4) Add to default WSL groups + sudo
for grp in adm cdrom sudo dip plugdev; do
  if getent group "$grp" >/dev/null; then
    usermod -aG "$grp" "$NIX_USER"
  fi
done
echo "▶ Added '$NIX_USER' to adm, cdrom, sudo, dip, plugdev"

# 5) Install Nix in single-user (no systemd) mode
echo "▶ Installing Nix (single-user mode)…"
eval "$NIX_INSTALL_COMMAND"

echo "✔ Nix installed. You remain as root."
