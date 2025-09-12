# Install Nginx
sudo dnf -y install nginx
sudo systemctl enable --now nginx
sudo systemctl status nginx 

#Configure firewall 
sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
sudo firewall-cmd --list-all


# Create a site root & Nginx server block
sudo mkdir -p /var/www/portfolio/html
sudo tee /var/www/portfolio/html/index.html > /dev/null <<'HTML'
<h1>It works! Amazon Linux + Nginx on EC2</h1>
<p>Served from /var/www/portfolio/html</p>
HTML

# Ownership (nginx typically runs as nginx:nginx on AlmaLinux)
sudo chown -R nginx:nginx /var/www/portfolio || true
sudo chmod -R 755 /var/www/portfolio

# Create server block
sudo tee /etc/nginx/conf.d/portfolio.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/portfolio/html;
    index index.html;
    access_log /var/log/nginx/portfolio.access.log;
    error_log  /var/log/nginx/portfolio.error.log;
    location / { try_files $uri $uri/ =404; }
}
EOF

# Test & reload
sudo nginx -t && sudo systemctl reload nginx

# Deploy from local files 
scp -i my-key.pem -r site/* deploy@EC2_PUBLIC_IP:/tmp/site/
ssh -i my-key.pem deploy@EC2_PUBLIC_IP \
"sudo rsync -av /tmp/site/ /var/www/portfolio/html/ && sudo chown -R nginx:nginx /var/www/portfolio"
