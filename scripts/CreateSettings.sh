#!/bin/bash

set -e

echo "[INFO] Génération du fichier de configuration (settings.yml)"
echo "---------------------------------------------------"

# Lecture des paramètres avec gestion des valeurs par défaut
echo "--- Configuration Globale ---"
read -p "Domaine principal [votre-domaine.fr] : " domain
domain=${domain:-"votre-domaine.fr"}

read -p "Timezone [Europe/Paris] : " timezone
timezone=${timezone:-"Europe/Paris"}

read -p "Utilisateur Admin [admin] : " admin_user
admin_user=${admin_user:-"admin"}

echo -e "\n--- Infrastructure Proxmox ---"
read -p "Endpoint Proxmox [https://pve.home.arpa:8006/api2/json] : " px_endpoint
px_endpoint=${px_endpoint:-"https://pve.home.arpa:8006/api2/json"}

read -p "Nom du noeud Proxmox [homelab] : " px_node
px_node=${px_node:-"homelab"}

read -p "Stockage [local-lvm] : " px_storage
px_storage=${px_storage:-"local-lvm"}

read -p "Utilisateur SSH [root] : " px_ssh_user
px_ssh_user=${px_ssh_user:-"root"}

# Création du fichier settings.yml à la racine
cat <<EOF > settings.yml
# --- CONFIGURATION GLOBALE ---
domain: "${domain}"
timezone: "${timezone}"
admin_user: "${admin_user}"

# --- INFRASTRUCTURE ---
proxmox:
  endpoint: "${px_endpoint}"
  node: "${px_node}"
  storage: "${px_storage}"
  ssh_user: "${px_ssh_user}"
EOF

echo "[SUCCESS] Fichier settings.yml généré avec succès."