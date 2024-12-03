
#!/bin/bash

LOG_FILE="/var/log/setup.log"

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo." | tee -a "$LOG_FILE"
    exit 1
fi


echo "Updating package list..." | tee -a "$LOG_FILE"
apt-get install -y gnupg curl &>> "$LOG_FILE"

curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor &>> "$LOG_FILE"

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

apt-get update

apt-get install -y mongodb-org &>> "$LOG_FILE"

apt-get install -y mongodb-org=7.0.2 mongodb-org-database=7.0.2 mongodb-org-server=7.0.2 mongodb-mongosh=7.0.2 mongodb-org-mongos=7.0.2 mongodb-org-tools=7.0.2

echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-mongosh hold" | sudo dpkg --set-selections

systemctl start mongod
systemctl daemon-reload
systemctl status mongod
systemctl enable mongod

if systemctl status mongod &>> "$LOG_FILE"; then
    echo "MongoDB installed and running successfully." | tee -a "$LOG_FILE"
else
    echo "MongoDB installation failed. Check the log file for details." | tee -a "$LOG_FILE"
    exit 1
fi

echo "Configuring MongoDB..." | tee -a "$LOG_FILE"
cat > /etc/mongod.conf <<EOF
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true
systemLog:
    destination: file
    logAppend: true
    path: /var/log/mongodb/mongod.log
net:
    port: 27017
    bindIp:
        -
EOF

systemctl restart mongod

if systemctl status mongod &>> "$LOG_FILE"; then
    echo "MongoDB configured successfully." | tee -a "$LOG_FILE"
else
    echo "MongoDB configuration failed. Check the log file for details." | tee -a "$LOG_FILE"
    exit 1
fi
