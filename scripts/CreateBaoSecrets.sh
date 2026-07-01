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
"$SCRIPT_DIR/InitOpenBao.sh" < /dev/tty

echo -e "\n[INFO] Saisie des secrets pour OpenBao"
echo "---------------------------------------------------"

export BAO_ADDR="http://192.168.10.15:8200"

echo "--- Komodo Database ---"
read -p "POSTGRES_USER : " komodo_db_user
read -p "POSTGRES_DB : " komodo_db_name
read -s -p "POSTGRES_PASSWORD : " komodo_db_pass
echo -e "\n"

echo "--- Komodo API ---"
read -s -p "API_KEY : " komodo_api_key
echo -e "\n"

echo "--- Cloudflared ---"
read -s -p "Tunnel Token : " cloudflared_token
echo -e "\n"

echo "--- Authentik ---"
read -s -p "AUTHENTIK_SECRET_KEY : " authentik_secret
echo ""
read -s -p "POSTGRES_PASSWORD : " authentik_db_pass
echo -e "\n"

echo "[INFO] Injection des secrets dans OpenBao en cours..."

bao kv put secret/komodo/database \
    POSTGRES_USER="$komodo_db_user" \
    POSTGRES_DB="$komodo_db_name" \
    POSTGRES_PASSWORD="$komodo_db_pass" > /dev/null

bao kv put secret/komodo/api \
    API_KEY="$komodo_api_key" > /dev/null

bao kv put secret/cloudflared/config \
    tunnel_token="$cloudflared_token" > /dev/null

bao kv put secret/authentik/config \
    AUTHENTIK_SECRET_KEY="$authentik_secret" \
    POSTGRES_PASSWORD="$authentik_db_pass" > /dev/null

echo "[SUCCESS] Opération terminée. Tous les secrets ont été injectés."