#!/bin/bash

echo "--- Générateur de configuration Terraform pour Proxmox ---"

# Lecture des entrées utilisateur
read -p "Adresse du host Proxmox (ex: https://192.168.1.10:8006): " proxmox_host
read -p "Utilisateur (ex: root): " user
read -p "Realm (ex: pam): " realm
read -p "Token ID (ex: terraform): " token_id
read -p "Secret du token: " secret
read -p "Chemin clé privée SSH (ex: ~/.ssh/id_rsa): " ssh_priv
read -p "Chemin clé publique SSH (ex: ~/.ssh/id_rsa.pub): " ssh_pub
read -p "Nom du stockage (ex: local-lvm): " storage

# Création du fichier
cat <<EOF > terraform/environments/production/terraform.tfvars
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

echo "---"
echo "Fichier terraform.tfvars généré avec succès !"