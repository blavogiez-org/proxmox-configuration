#!/bin/bash

set -e

echo "==========================================================="
echo "[INFO] Initialisation de l'infrastructure Proxmox GitOps"
echo "==========================================================="

REPO_URL="https://github.com/jobacogiez-org/proxmox-gitops.git"
REPO_DIR="proxmox-gitops"

if ! command -v git >/dev/null 2>&1; then
    echo "[ERROR] Git n'est pas installé sur cette machine. Installation requise."
    exit 1
fi

echo -e "\n[ÉTAPE 0/5] Récupération du dépôt Git..."
if [ -d "$REPO_DIR" ]; then
    echo "[INFO] Le dossier '$REPO_DIR' existe déjà. Mise à jour (git pull)..."
    cd "$REPO_DIR"
    git pull origin main
else
    echo "[INFO] Clonage depuis $REPO_URL..."
    git clone "$REPO_URL"
    cd "$REPO_DIR"
fi

echo "[INFO] Configuration des permissions d'exécution..."
chmod +x CheckDependences.sh CreateTfvars.sh LunchTerraform.sh CreateBaoSecrets.sh

echo -e "\n[ÉTAPE 1/5] Vérification des dépendances..."
./CheckDependences.sh

echo -e "\n[ÉTAPE 2/5] Création de la configuration Proxmox (tfvars)..."
./CreateTfvars.sh < /dev/tty

TFVARS_PATH="terraform/environments/production/terraform.tfvars"

echo -e "\n[ÉTAPE 3/5] Déploiement de la couche 'bootstrap' (Terraform)..."
./LunchTerraform.sh "$TFVARS_PATH" "bootstrap"

echo -e "\n[ÉTAPE 4/5] Injection des secrets dans OpenBao..."
read -p "Saisissez l'IP physique de votre Proxmox pour configurer le routage vers OpenBao (ex: 192.168.1.100) : " PROXMOX_IP < /dev/tty
./CreateBaoSecrets.sh "$PROXMOX_IP" < /dev/tty

echo -e "\n[ÉTAPE 5/5] Déploiement de la couche 'core' (Terraform)..."
./LunchTerraform.sh "$TFVARS_PATH" "core"

echo -e "\n==========================================================="
echo "[SUCCESS] L'initialisation de l'infrastructure est terminée."
echo "==========================================================="