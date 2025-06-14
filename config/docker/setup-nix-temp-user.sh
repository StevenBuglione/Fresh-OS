#!/usr/bin/env bash
set -euo pipefail

#—— Build‐time overrides via ARG/ENV ——
: "${NIX_USER:=sbuglione}"
: "${NIX_UID:=1000}"
: "${NIX_GID:=1000}"
: "${NIX_PASSWORD:=}"    
: "${NIX_INSTALL_COMMAND:=curl -fsSL https://install.determinate.systems/nix \
    | sh -s -- install linux --determinate --init none --no-confirm}"

echo "▶ Installing host prerequisites (git, gettext)…"
apt-get update -qq
apt-get install -y --no-install-recommends git gettext

echo "▶ Creating group GID=${NIX_GID} → ${NIX_USER} (if missing)…"
if ! getent group "${NIX_GID}" >/dev/null; then
  groupadd --gid "${NIX_GID}" "${NIX_USER}"
fi

echo "▶ Creating user UID=${NIX_UID} → ${NIX_USER} (if missing)…"
if ! id "${NIX_USER}" &>/dev/null; then
  useradd \
    --uid "${NIX_UID}" \
    --gid "${NIX_GID}" \
    --shell /bin/bash \
    --create-home \
    "${NIX_USER}"
fi

echo "▶ Setting or locking password for ${NIX_USER}…"
if [[ -n "${NIX_PASSWORD}" ]]; then
  echo "${NIX_USER}:${NIX_PASSWORD}" | chpasswd
else
  passwd -l "${NIX_USER}" >/dev/null 2>&1 || true
fi

echo "▶ Adding ${NIX_USER} to adm, cdrom, sudo, dip, plugdev…"
for grp in adm cdrom sudo dip plugdev; do
  getent group "$grp" >/dev/null && usermod -aG "$grp" "$NIX_USER"
done

echo "▶ Installing Nix (single-user mode)…"
eval "${NIX_INSTALL_COMMAND}"

echo "▶ Fixing ownership of /nix…"
chown -R "${NIX_USER}:${NIX_USER}" /nix

# A helper wrapper: source Nix’s profile then run the given command
run_as_nix() {
  su -l "${NIX_USER}" -s /bin/bash -c \
    ". /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && $*"
}

echo "▶ Installing Home Manager from the channel and building it…"
run_as_nix "nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager \
            && nix-channel --update \
            && nix-shell '<home-manager>' -A install"


echo "▶ Cloning your Fresh-OS-Nix flake…"
run_as_nix "git clone https://github.com/StevenBuglione/Fresh-OS-Nix.git /home/${NIX_USER}/.config/nix"

echo "▶ Patching flake.nix → setting username = \"${NIX_USER}\"…"
run_as_nix "sed -i 's|username = \\\".*\\\";|username = \\\"${NIX_USER}\\\";|g' /home/${NIX_USER}/.config/nix/flake.nix"

run_as_nix "cd /home/${NIX_USER}/.config/nix && git add ."

echo "▶ Applying your Home Manager configuration…"
run_as_nix "home-manager switch --flake /home/${NIX_USER}/.config/nix#user"

echo "✔ All done! Nix & Home Manager are installed and your flake is activated. You remain as root."
