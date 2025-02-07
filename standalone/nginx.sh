#!/bin/bash

LOG_FILE="/var/log/nginx.log"

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo." | tee -a "$LOG_FILE"
    exit 1
fi

echo "Installing Nginx..." | tee -a "$LOG_FILE"
apt install -y nginx &>> "$LOG_FILE"

if systemctl status nginx &>> "$LOG_FILE"; then
    echo "Nginx installed and running successfully." | tee -a "$LOG_FILE"
else
    echo "Nginx installation failed. Check the log file for details." | tee -a "$LOG_FILE"
    exit 1
fi

echo "Configuring Nginx..." | tee -a "$LOG_FILE"
cat > /etc/nginx/sites-available/test <<EOF
server {
    listen 80;
    server_name admin.test.com;

    location / {
        proxy_pass http://localhost:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:8080/api;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

ln -s /etc/nginx/sites-available/test /etc/nginx/sites-enabled/test
rm /etc/nginx/sites-enabled/default

systemctl restart nginx &>> "$LOG_FILE"

if systemctl status nginx &>> "$LOG_FILE"; then
    echo "Nginx configured successfully." | tee -a "$LOG_FILE"
else
    echo "Nginx configuration failed. Check the log file for details." | tee -a "$LOG_FILE"
    exit 1
fi

echo "Installing Let's Encrypt..." | tee -a "$LOG_FILE"
apt install -y certbot python3-certbot-nginx &>> "$LOG_FILE"

echo "Configuring Let's Encrypt..." | tee -a "$LOG_FILE"
certbot --nginx -d admin.test.com --non-interactive --agree-tos -m

if systemctl status nginx &>> "$LOG_FILE"; then
    echo "Let's Encrypt configured successfully." | tee -a "$LOG_FILE"
else
    echo "Let's Encrypt configuration failed. Check the log file for details." | tee -a "$LOG_FILE"
    exit 1
fi

echo "Nginx setup complete." | tee -a "$LOG_FILE"
