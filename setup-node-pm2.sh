#!/bin/bash

LOG_FILE="/var/log/setup.log"

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo." | tee -a "$LOG_FILE"
    exit 1
fi

echo "Updating package list..." | tee -a "$LOG_FILE"
apt update &>> "$LOG_FILE"

echo "Installing Node.js 20..." | tee -a "$LOG_FILE"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &>> "$LOG_FILE"
apt install -y nodejs &>> "$LOG_FILE"

if node -v &>> "$LOG_FILE"; then
    echo "Node.js installed successfully." | tee -a "$LOG_FILE"
else
    echo "Node.js installation failed. Check the log file for details." | tee -a "$LOG_FILE"
    exit 1
fi

echo "Installing PM2..." | tee -a "$LOG_FILE"
npm install -g pm2 &>> "$LOG_FILE"

if pm2 -v &>> "$LOG_FILE"; then
    echo "PM2 installed successfully." | tee -a "$LOG_FILE"
else
    echo "PM2 installation failed. Check the log file for details." | tee -a "$LOG_FILE"
    exit 1
fi

echo "=================================" | tee -a "$LOG_FILE"
echo "Setup completed successfully!" | tee -a "$LOG_FILE"
echo "Node.js version: $(node -v)" | tee -a "$LOG_FILE"
echo "NPM version: $(npm -v)" | tee -a "$LOG_FILE"
echo "PM2 version: $(pm2 -v)" | tee -a "$LOG_FILE"
echo "Log file available at: $LOG_FILE" | tee -a "$LOG_FILE"
echo "=================================" | tee -a "$LOG_FILE"
