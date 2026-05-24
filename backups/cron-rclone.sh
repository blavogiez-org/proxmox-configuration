#!/bin/bash
# m h  dom mon dow   command
# 0 1  */1 *   *     bash /var/lib/vz/cron-rclone.sh

set -euo pipefail

S3_PROVIDER="scaleway"
BUCKET_NAME="blavogiez-proxmox-backups"

RETENT=true
RETENTION="3d"
DUMPDIR="/var/lib/vz/dump"
REMOTE="${S3_PROVIDER}:${BUCKET_NAME}/homelab/vzdump"
REMOTE_DATED="${REMOTE}/$(date +%F)"

vzdump --all --dumpdir "$DUMPDIR" --mode snapshot --compress zstd

rclone copy "$DUMPDIR" "$REMOTE_DATED" \
  --log-file=/var/log/proxmox-scaleway-backup.log \
  --log-level=INFO

if [[ "$RETENT" == "true" ]]; then
  rclone delete "$REMOTE" \
    --min-age "$RETENTION" \
    --log-file=/var/log/proxmox-scaleway-retention.log \
    --log-level=INFO || true
fi


# vu qu'on est en set -e si on arrive là c'est que le s3 provider a bien reçu le backup 
# dans mon cas je préfère clean en local (manque d'espace) 
# petite securite vu que c'est une variable
if [[ "$DUMPDIR" == "/var/lib/vz/dump" ]]; then
  rm -rf "$DUMPDIR"/*
fi
