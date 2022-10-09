#!/bin/bash

#fix ownership
chown -R backup:backup /etc/proxmox-backup
chmod -R 700 /etc/proxmox-backup
#switch user for run

#Fix user accounts
chsh -s /bin/bash backup
usermod -a -G backup root
usermod -g backup root
usermod -aG sudo backup

systemctl start proxmox-backup
systemctl start proxmox-backup-proxy

while /bin/true; do
  sleep 60
done