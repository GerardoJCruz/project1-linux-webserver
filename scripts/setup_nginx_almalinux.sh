#!/usr/bin/env bash
set -euo pipefail

echo "[*] Updating system..."
sudo dnf -y update

echo "[*] Installing Nginx..."
sudo dnf -y install nginx

echo "[*] Enabling and starting nginx..."
sudo systemctl enable --now nginx

echo "[*] Enabling firewalld and opening ports..."
sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-service=ssh || true
sudo firewall-cmd --permanent --add-service=http || true
sudo firewall-cmd --permanent --add-service=https || true
sudo firewall-cmd --reload

echo "[*] Creating site root..."
sudo mkdir -p /var/www/portfolio/html
sudo tee /var/www/portfolio/html/index.html > /dev/null <<'HTML'
<h1>It works! AlmaLinux + Nginx on EC2</h1>
<p>Served from /var/www/portfolio/html</p>
HTML

echo "[*] Set ownership and permissions..."
# On RHEL-like systems, nginx often runs as nginx:nginx
sudo chown -R nginx:nginx /var/www/portfolio || sudo chown -R www-data:www-data /var/www/portfolio || true
sudo chmod -R 755 /var/www/portfolio

echo "[*] SELinux: configure context if semanage available..."
if ! command -v semanage >/dev/null 2>&1; then
  echo "[*] Installing policycoreutils-python-utils for semanage..."
  sudo dnf -y install policycoreutils-python-utils || true
fi
if command -v semanage >/dev/null 2>&1; then
  sudo semanage fcontext -a -t httpd_sys_content_t "/var/www/portfolio(/.*)?" 2>/dev/null || true
  sudo restorecon -Rv /var/www/portfolio || true
fi

echo "[*] Create nginx config in /etc/nginx/conf.d/portfolio.conf ..."
sudo tee /etc/nginx/conf.d/portfolio.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/portfolio/html;
    index index.html;
    access_log /var/log/nginx/portfolio.access.log;
    error_log  /var/log/nginx/portfolio.error.log;
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

echo "[*] Test and reload nginx..."
sudo nginx -t && sudo systemctl reload nginx

echo "[*] Done. Visit the server's public IP in your browser."
