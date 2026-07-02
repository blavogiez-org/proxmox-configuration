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

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/InitOpenBao.sh" < /dev/tty

export BAO_ADDR="http://192.168.10.15:8200"

echo -e "\n[INFO] Authentification OpenBao"
echo "---------------------------------------------------"
# On tente de récupérer le token généré automatiquement par l'initialisation
if [ -f "/tmp/bao_keys_raw.json" ]; then
    echo "[INFO] Récupération automatique du Token Root..."
    export BAO_TOKEN=$(jq -r '.root_token' /tmp/bao_keys_raw.json)
else
    # Si le fichier n'existe pas (serveur déjà initialisé avant), on le demande à l'utilisateur
    read -s -p "Veuillez entrer le Token Root : " user_token
    echo ""
    export BAO_TOKEN="$user_token"
fi

echo -e "\n[INFO] Vérification du moteur de secrets"
echo "---------------------------------------------------"
# On s'assure que le chemin "secret/" existe bien avant d'y injecter des données
if ! bao secrets list | grep -q "^secret/"; then
    echo "[INFO] Activation du moteur Key-Value (v2) sur le chemin 'secret/'..."
    bao secrets enable -path=secret kv-v2 > /dev/null
    echo "[SUCCESS] Moteur activé."
else
    echo "[INFO] Le moteur de secrets est déjà actif."
fi

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

bao kv put secret/authentik/config \
    AUTHENTIK_SECRET_KEY="$authentik_secret" \
    POSTGRES_PASSWORD="$authentik_db_pass" > /dev/null

echo "[SUCCESS] Opération terminée. Tous les secrets ont été injectés."