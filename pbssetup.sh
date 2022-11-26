#!/bin/bash

chsh -s /bin/bash backup
usermod -a -G backup root
usermod -g backup root
usermod -aG sudo backup

chown -R backup:backup /etc/proxmox-backup
chown -R backup:backup /var/log/proxmox-backup
chown -R backup:backup /var/lib/proxmox-backup/

chmod -R 700 /etc/proxmox-backup

systemctl start proxmox-backup
systemctl start proxmox-backup-proxy

while /bin/true; do
  sleep 60
done