#!/bin/bash

set -e

if [ "$#" -ne 2 ]; then
    echo "Erreur : Nombre d'arguments invalide."
    echo "Usage : $0 <chemin_tfvars> <couche_terraform>"
    echo "Exemple : $0 ./terraform.tfvars bootstrap"
    exit 1
fi

TFVARS_FILE="$1"
LAYER="$2"

if [ ! -f "$TFVARS_FILE" ]; then
    echo "Erreur : Le fichier '$TFVARS_FILE' est introuvable."
    exit 1
fi

TFVARS_ABS_PATH=$(realpath "$TFVARS_FILE")
TARGET_DIR="terraform/environments/production/$LAYER"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Erreur : Le répertoire cible '$TARGET_DIR' est introuvable."
    exit 1
fi

cd "$TARGET_DIR"

echo "Initialisation de Terraform (couche : $LAYER)..."
terraform init

echo "Application de la configuration Terraform..."
terraform apply -var-file="$TFVARS_ABS_PATH"