#!/bin/bash

set -e

TFVARS_FILE="terraform/environments/production/terraform.tfvars"
TFVARS_TEMPLATE="terraform/environments/production/terraform.tfvars.j2"

echo "[INFO] Génération de la configuration Terraform pour Proxmox"
echo "---------------------------------------------------"

if [ ! -f "$TFVARS_TEMPLATE" ]; then
    echo "[ERROR] Template introuvable : $TFVARS_TEMPLATE"
    exit 1
fi

if [ -f "$TFVARS_FILE" ]; then
    read -p "Le fichier '$TFVARS_FILE' existe déjà. Voulez-vous l'écraser ? (o/N) : " overwrite < /dev/tty
    if [[ ! "$overwrite" =~ ^[OoyY] ]]; then
        echo "[INFO] Conservation du fichier existant. Saisie ignorée."
        exit 0
    fi
    echo "[INFO] Écrasement du fichier confirmé."
fi

read -r -p "Adresse du host Proxmox (ex: https://192.168.1.10:8006) : " proxmox_host
read -r -p "Utilisateur (ex: terraform) : " proxmox_user
read -r -p "Realm (ex: pve) : " proxmox_realm
read -r -p "Token ID (ex: tf) : " proxmox_token_id
read -r -s -p "Secret du token (champ masqué): " proxmox_token_secret
echo ""
read -r -p "Chemin clé privée SSH (ex: ~/.ssh/id_rsa) : " ssh_private_key_path
read -r -p "Chemin clé publique SSH (ex: ~/.ssh/id_rsa.pub) : " ssh_public_key_path
read -r -p "Nom du stockage (ex: local-lvm) : " storage
read -r -p "Nom du stockage pour les backups minimaux (ex: local-lvm) : " backup_storage
read -r -p "Nom du node (ex: pve) : " node_name

mkdir -p "$(dirname "$TFVARS_FILE")"

TF_PROXMOX_HOST="${proxmox_host%/}" \
TF_PROXMOX_USER="$proxmox_user" \
TF_PROXMOX_REALM="$proxmox_realm" \
TF_PROXMOX_TOKEN_ID="$proxmox_token_id" \
TF_PROXMOX_TOKEN_SECRET="$proxmox_token_secret" \
TF_PROXMOX_SSH_PRIVATE_KEY_PATH="$ssh_private_key_path" \
TF_PROXMOX_SSH_PUBLIC_KEY_PATH="$ssh_public_key_path" \
TF_STORAGE="$storage" \
TF_BACKUP_STORAGE="$backup_storage" \
TF_NODE_NAME="$node_name" \
j2 "$TFVARS_TEMPLATE" > "$TFVARS_FILE"

echo "[SUCCESS] Fichier terraform.tfvars généré avec succès !"
