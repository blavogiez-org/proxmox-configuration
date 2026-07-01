#!/bin/bash

# Interrompt le script au moindre échec d'une commande
set -e

echo "==========================================================="
echo "[INFO] Initialisation de l'infrastructure Proxmox GitOps"
echo "==========================================================="

REPO_URL="https://github.com/jobacogiez-org/proxmox-gitops.git"
REPO_DIR="proxmox-gitops"
BRANCH="26-remplissage-assisté-des-secrets-du-vault-openbao"

# 1. Vérification de Git sur la machine hôte
if ! command -v git >/dev/null 2>&1; then
    echo "[ERROR] Git n'est pas installé sur cette machine. Installation requise."
    exit 1
fi

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
chmod +x scripts/CheckDependences.sh scripts/CreateTfvars.sh scripts/LunchTerraform.sh scripts/CreateBaoSecrets.sh scripts/CreateSettings.sh scripts/InitOpenBao.sh

echo -e "\n[ÉTAPE 1/6] Vérification des dépendances..."
./scripts/CheckDependences.sh

echo -e "\n[ÉTAPE 2/6] Création de la configuration Proxmox (tfvars)..."
./scripts/CreateTfvars.sh < /dev/tty

TFVARS_PATH="terraform/environments/production/terraform.tfvars"

echo -e "\n[ÉTAPE 3/6] Déploiement de la couche 'bootstrap' (Terraform)..."
./scripts/LunchTerraform.sh "$TFVARS_PATH" "bootstrap"

echo -e "\n[ÉTAPE 4/6] Injection des secrets dans OpenBao..."
read -p "Saisissez l'IP physique de votre Proxmox pour configurer le routage vers OpenBao (ex: 192.168.1.100) : " PROXMOX_IP < /dev/tty
./scripts/CreateBaoSecrets.sh "$PROXMOX_IP" < /dev/tty

echo -e "\n[ÉTAPE 5/6] Génération de la configuration globale (settings.yml)..."
./scripts/CreateSettings.sh < /dev/tty

echo -e "\n[ÉTAPE 6/6] Déploiement de la couche 'core' (Terraform)..."
./scripts/LunchTerraform.sh "$TFVARS_PATH" "core"

echo -e "\n==========================================================="
echo "[SUCCESS] L'initialisation de l'infrastructure est terminée."
echo "==========================================================="