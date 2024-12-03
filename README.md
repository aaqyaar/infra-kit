# Server Scripts

## Table of Contents

1. [Initial Server Setup](#initial-server-setup)

## Initial Server Setup

### Update and Upgrade

```bash
sudo apt update
sudo apt upgrade
```

### Create a New User

```bash
sudo adduser username
sudo usermod -aG sudo username
```

### Set Up SSH Key

```bash
ssh-keygen
ssh-copy-id username@server_ip
```

### Disable Password Authentication

```bash
sudo nano /etc/ssh/sshd_config
```

Change `PasswordAuthentication` to `no` and restart the SSH service.

```bash
sudo systemctl restart ssh
```

### Set Up Firewall

```bash
sudo ufw allow OpenSSH
sudo ufw enable
```
