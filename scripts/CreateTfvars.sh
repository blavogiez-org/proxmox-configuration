#!/bin/bash

set -e

TFVARS_FILE="terraform/environments/production/terraform.tfvars"

echo "[INFO] Génération de la configuration Terraform pour Proxmox"
echo "---------------------------------------------------"

# Vérification si le fichier existe déjà
if [ -f "$TFVARS_FILE" ]; then
    read -p "Le fichier '$TFVARS_FILE' existe déjà. Voulez-vous l'écraser ? (o/N) : " overwrite < /dev/tty
    if [[ ! "$overwrite" =~ ^[OoyY] ]]; then
        echo "[INFO] Conservation du fichier existant. Saisie ignorée."
        exit 0
    fi
    echo "[INFO] Écrasement du fichier confirmé."
fi

# Lecture des entrées utilisateur
read -p "Adresse du host Proxmox (ex: https://192.168.1.10:8006) : " proxmox_host
read -p "Utilisateur (ex: root) : " user
read -p "Realm (ex: pam) : " realm
read -p "Token ID (ex: terraform) : " token_id
read -s -p "Secret du token : " secret
echo "" # Retour à la ligne après le mot de passe caché
read -p "Chemin clé privée SSH (ex: ~/.ssh/id_rsa) : " ssh_priv
read -p "Chemin clé publique SSH (ex: ~/.ssh/id_rsa.pub) : " ssh_pub
read -p "Nom du stockage (ex: local-lvm) : " storage

# Création du répertoire de destination au cas où il n'existerait pas encore
mkdir -p "$(dirname "$TFVARS_FILE")"

# Création du fichier
cat <<EOF > "$TFVARS_FILE"
# Configuration Proxmox
proxmox_endpoint  = "$proxmox_host/api2/json"
proxmox_api_token = "$user@$realm!$token_id=$secret"

# Sécurité TLS
proxmox_insecure = true

# Configuration SSH
proxmox_ssh_username         = "root"
proxmox_ssh_private_key_path = "$ssh_priv"
ssh_public_key_path          = "$ssh_pub"

# Infrastructure & Runner
storage      = "$storage"
EOF

echo "[SUCCESS] Fichier terraform.tfvars généré avec succès !"