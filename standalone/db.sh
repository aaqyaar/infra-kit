
#!/bin/bash

LOG_FILE="/var/log/db.log"

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo." | tee -a "$LOG_FILE"
    exit 1
fi

echo "Installing PostgreSQL..." | tee -a "$LOG_FILE"
apt update && apt install -y postgresql postgresql-contrib &>> "$LOG_FILE"

if [ $? -ne 0 ]; then
    echo "PostgreSQL installation failed. Exiting..." | tee -a "$LOG_FILE"
    exit 1
fi

systemctl start postgresql.service &>> "$LOG_FILE"

if systemctl status postgresql &>> "$LOG_FILE"; then
    echo "PostgreSQL installed and running successfully." | tee -a "$LOG_FILE"
else
    echo "PostgreSQL installation failed. Check the log file for details." | tee -a "$LOG_FILE"
    exit 1
fi

echo "Installing Redis..." | tee -a "$LOG_FILE"
apt update && apt install -y redis-server &>> "$LOG_FILE"

if systemctl status redis &>> "$LOG_FILE"; then
    echo "Redis installed successfully." | tee -a "$LOG_FILE"
else
    echo "Redis installation failed. Check the log file for details." | tee -a "$LOG_FILE"
    exit 1
fi