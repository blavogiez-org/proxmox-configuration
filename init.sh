#!/bin/bash

# Interrompt le script au moindre échec d'une commande
set -e

echo "==========================================================="
echo "[INFO] Initialisation de l'infrastructure Proxmox GitOps"
echo "==========================================================="

REPO_URL="https://github.com/jobacogiez-org/proxmox-gitops.git"
REPO_DIR="proxmox-gitops"
BRANCH="26-remplissage-assisté-des-secrets-du-vault-openbao"

echo -e "\n[ÉTAPE 0/6] Récupération du dépôt Git..."
if [ -d "$REPO_DIR" ]; then
    echo "[INFO] Le dossier '$REPO_DIR' existe déjà. Mise à jour (git pull)..."
    cd "$REPO_DIR"
    git checkout "$BRANCH"
    git pull origin "$BRANCH"
else
    echo "[INFO] Clonage de la branche $BRANCH depuis $REPO_URL..."
    git clone -b "$BRANCH" "$REPO_URL"
    cd "$REPO_DIR"
fi

echo "[INFO] Configuration des permissions d'exécution..."
chmod +x scripts/check_dependencies.sh scripts/create_tfvars_credentials.sh scripts/launch_terraform_by_layer.sh scripts/create_main_vault_secrets.sh scripts/create_repo_settings.sh scripts/initialize_vault.sh

echo -e "\n[ÉTAPE 1/6] Vérification des dépendances..."
./scripts/check_dependencies.sh

echo -e "\n[ÉTAPE 2/6] Création de la configuration Proxmox (tfvars)..."
./scripts/create_tfvars_credentials.sh < /dev/tty

TFVARS_PATH="terraform/environments/production/terraform.tfvars"

echo -e "\n[ÉTAPE 3/6] Déploiement de la couche 'bootstrap' (Terraform)..."
./scripts/launch_terraform_by_layer.sh "$TFVARS_PATH" "bootstrap"

echo -e "\n[ÉTAPE 4/6] Injection des secrets dans OpenBao..."
read -r -p "Saisissez l'IP physique de votre Proxmox pour configurer le routage vers OpenBao (ex: 192.168.1.100) : " PROXMOX_IP < /dev/tty
source ./scripts/create_main_vault_secrets.sh "$PROXMOX_IP" < /dev/tty

echo -e "\n[ÉTAPE 5/6] Génération de la configuration globale (settings.yml)..."
./scripts/create_repo_settings.sh < /dev/tty

echo -e "\n[ÉTAPE 6/6] Déploiement de la couche 'core' (Terraform)..."
./scripts/launch_terraform_by_layer.sh "$TFVARS_PATH" "core"

echo -e "\n==========================================================="
echo "[SUCCESS] L'initialisation de l'infrastructure est terminée."
echo "==========================================================="
