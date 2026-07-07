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

if ! ip route show | grep -q "192.168.10.0/24 via $proxmox_ip"; then
    echo "[INFO] Ajout de la route vers 192.168.10.0/24 (privilèges administrateur requis)..."
    sudo ip route add 192.168.10.0/24 via "$proxmox_ip"
    echo "[SUCCESS] Route ajoutée."
else
    echo "[INFO] La route est déjà configurée."
fi

echo -e "\n[INFO] Saisie des secrets pour OpenBao"

export BAO_ADDR="https://192.168.10.15"
# certificat interne temporaire, à remplacer quand on aura fait cert public
export BAO_SKIP_VERIFY=true

echo "--- connectez vous à openbao avec le token qui est demandé ---"
bao login 
# il affiche le token ce qui est un peu chiant, on peut faire ça aussi
# bao login no-print
# et éventuellement no store 
# bao login -no-store

echo '-activation du moteur KV v2 ---'

if bao secrets list -format=json | grep -q '"secret/"'; then
    echo "[INFO] Le moteur secret/ est déjà actif."
else
    bao secrets enable -path=secret kv-v2
fi



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

bao kv put -mount=secret komodo \
    POSTGRES_USER="$komodo_db_user" \
    POSTGRES_DB="$komodo_db_name" \
    POSTGRES_PASSWORD="$komodo_db_pass" \
    API_KEY="$komodo_api_key" > /dev/null
    

bao kv put -mount=secret cloudflared \
    tunnel_token="$cloudflared_token" > /dev/null

bao kv put -mount=secret authentik \
    AUTHENTIK_SECRET_KEY="$authentik_secret" \
    POSTGRES_PASSWORD="$authentik_db_pass" > /dev/null

echo "[SUCCESS] Opération terminée. Tous les secrets ont été injectés."
echo "quelques tests qu'on fait à la fin, commenter pour désactiver"
bao secrets list 
echo "si ca ne va pas, regardez dans l'ui à $BAO_ADDR"
