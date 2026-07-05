#!/bin/bash

set -e

SETTINGS_FILE="settings.yml"
SETTINGS_TEMPLATE="settings.yml.j2"

echo "[INFO] Génération du fichier de configuration (settings.yml)"
echo "---------------------------------------------------"

echo "--- Configuration Globale ---"
read -r -p "Domaine principal [votre-domaine.fr] : " domain
domain=${domain:-"votre-domaine.fr"}

read -r -p "Timezone [Europe/Paris] : " timezone
timezone=${timezone:-"Europe/Paris"}

read -r -p "Utilisateur Admin [admin] : " admin_user
admin_user=${admin_user:-"admin"}

echo -e "\n--- Infrastructure Proxmox ---"
read -r -p "Endpoint Proxmox [https://pve.home.arpa:8006/api2/json] : " px_endpoint
px_endpoint=${px_endpoint:-"https://pve.home.arpa:8006/api2/json"}

read -r -p "Nom du noeud Proxmox [homelab] : " px_node
px_node=${px_node:-"homelab"}

read -r -p "Stockage [local-lvm] : " px_storage
px_storage=${px_storage:-"local-lvm"}

read -r -p "Utilisateur SSH [root] : " px_ssh_user
px_ssh_user=${px_ssh_user:-"root"}

SETTINGS_DOMAIN="$domain" \
SETTINGS_TIMEZONE="$timezone" \
SETTINGS_ADMIN_USER="$admin_user" \
SETTINGS_PROXMOX_ENDPOINT="$px_endpoint" \
SETTINGS_PROXMOX_NODE="$px_node" \
SETTINGS_PROXMOX_STORAGE="$px_storage" \
SETTINGS_PROXMOX_SSH_USER="$px_ssh_user" \
j2 "$SETTINGS_TEMPLATE" > "$SETTINGS_FILE"

echo "[SUCCESS] Fichier settings.yml généré avec succès."
