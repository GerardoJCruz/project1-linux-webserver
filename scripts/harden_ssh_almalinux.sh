#!/usr/bin/env bash
set -euo pipefail

USER="${1:-deploy}"

echo "[*] Creating user: $USER (if not exists) and adding to wheel group..."
if ! id "$USER" >/dev/null 2>&1; then
  sudo adduser "$USER"
fi
sudo usermod -aG wheel "$USER" || true

echo "[*] Creating .ssh for $USER and setting permissions..."
sudo -u "$USER" mkdir -p /home/$USER/.ssh
sudo -u "$USER" chmod 700 /home/$USER/.ssh

echo "[*] Paste your PUBLIC SSH KEY now, then CTRL-D:"
sudo tee /home/$USER/.ssh/authorized_keys
sudo chown -R $USER:$USER /home/$USER/.ssh
sudo chmod 600 /home/$USER/.ssh/authorized_keys

echo "[*] Backup sshd_config and harden SSH (disable password auth, disable root login)..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config || true
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config || true
sudo systemctl restart sshd

echo "[*] Done. IMPORTANT: Test logging in as $USER before closing this session."
