#!/bin/bash

set -e

# Vérification du paramètre d'entrée
if [ -z "$1" ]; then
    echo "[ERROR] L'adresse IP physique de Proxmox est requise en paramètre."
    echo "Usage : $0 <IP_PROXMOX>"
    echo "Exemple : $0 192.168.1.100"
    exit 1
fi

proxmox_ip="$1"

echo "[INFO] Configuration du routage réseau vers Proxmox ($proxmox_ip)"
echo "---------------------------------------------------"

if ! ip route show | grep -q "192.168.10.0/24 via $proxmox_ip"; then
    echo "[INFO] Ajout de la route vers 192.168.10.0/24 (privilèges administrateur requis)..."
    sudo ip route add 192.168.10.0/24 via "$proxmox_ip"
    echo "[SUCCESS] Route ajoutée."
else
    echo "[INFO] La route est déjà configurée."
fi

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/InitOpenBao.sh" < /dev/tty

export BAO_ADDR="http://192.168.10.15:8200"
export VAULT_ADDR="$BAO_ADDR" # Ajout pour la compatibilité Terraform

echo -e "\n[INFO] Authentification OpenBao"
echo "---------------------------------------------------"
# On tente de récupérer le token généré automatiquement par l'initialisation
if [ -f "/tmp/bao_keys_raw.json" ]; then
    echo "[INFO] Récupération automatique du Token Root..."
    export BAO_TOKEN=$(jq -r '.root_token' /tmp/bao_keys_raw.json)
    export VAULT_TOKEN="$BAO_TOKEN" # Ajout pour la compatibilité Terraform
else
    # Si le fichier n'existe pas (serveur déjà initialisé avant), on le demande à l'utilisateur
    read -s -p "Veuillez entrer le Token Root : " user_token
    echo ""
    export BAO_TOKEN="$user_token"
    export VAULT_TOKEN="$user_token" # Ajout pour la compatibilité Terraform
fi

echo -e "\n[INFO] Vérification et configuration stricte du moteur KV-v2"
echo "---------------------------------------------------"

# Si le chemin secret/ existe déjà (peu importe sa version), on le supprime pour repartir au propre
if bao secrets list | grep -q "^secret/"; then
    echo "[INFO] Ancien moteur détecté. Nettoyage en cours..."
    bao secrets disable secret/ > /dev/null
fi

# On recrée le moteur en forçant explicitement la Version 2
echo "[INFO] Activation du moteur Key-Value (v2) sur le chemin 'secret/'..."
bao secrets enable -path=secret kv-v2 > /dev/null
echo "[SUCCESS] Moteur KV-v2 activé et prêt."

# On force le versioning v2 pour garantir le chemin secret/data/... attendu par Terraform
bao kv enable-versioning secret/ > /dev/null 2>&1 || true

echo -e "\n[INFO] Saisie des secrets pour OpenBao"
echo "---------------------------------------------------"

echo "--- Cloudflared ---"
read -s -p "Tunnel Token : " cloudflared_token
echo -e "\n"

echo "--- Authentik ---"
read -s -p "AUTHENTIK_SECRET_KEY : " authentik_secret
echo ""
read -s -p "POSTGRES_PASSWORD : " authentik_db_pass
echo -e "\n"

echo "[INFO] Injection des secrets dans OpenBao en cours..."

bao kv put secret/cloudflared/config \
    tunnel_token="$cloudflared_token" > /dev/null

# Les noms de clés (secret_key et pg_pass) correspondent désormais au code Terraform
bao kv put secret/authentik/config \
    secret_key="$authentik_secret" \
    pg_pass="$authentik_db_pass" > /dev/null

echo "[SUCCESS] Opération terminée. Tous les secrets ont été injectés."