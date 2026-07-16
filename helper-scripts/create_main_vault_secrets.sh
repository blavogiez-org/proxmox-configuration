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

echo "--- Proxmox GitOps ---"
read -s -p "Token API Proxmox complet (user@realm!token-id=secret) : " proxmox_api_token
echo -e "\n"

echo "--- Cloudflared ---"
read -r -p "Tunnel UUID : " cloudflared_tunnel_id
read -r -p "Chemin du fichier de credentials (<UUID>.json) : " cloudflared_credentials_file
cloudflared_credentials_json="$(< "$cloudflared_credentials_file")"
echo

echo "--- Authentik ---"
read -s -p "AUTHENTIK_SECRET_KEY : " authentik_secret
echo ""
read -s -p "POSTGRES_PASSWORD : " authentik_db_pass
echo -e "\n"

echo "--- Grafana ---"
read -s -p "Mot de passe administrateur : " grafana_admin_password
echo -e "\n"

echo "--- Prometheus PVE Exporter ---"
read -s -p "Valeur du token API Proxmox : " pve_exporter_token_value
echo -e "\n"

echo "[INFO] Injection des secrets dans OpenBao en cours..."

bao kv put -mount=secret komodo \
    POSTGRES_USER="$komodo_db_user" \
    POSTGRES_DB="$komodo_db_name" \
    POSTGRES_PASSWORD="$komodo_db_pass" \
    API_KEY="$komodo_api_key" > /dev/null

bao kv put -mount=secret proxmox-gitops \
    proxmox_api_token="$proxmox_api_token" > /dev/null

bao kv put -mount=secret cloudflared \
    tunnel_id="$cloudflared_tunnel_id" \
    credentials_json="$cloudflared_credentials_json" > /dev/null

bao kv put -mount=secret authentik \
    secret_key="$authentik_secret" \
    pg_pass="$authentik_db_pass" > /dev/null

bao kv put -mount=secret grafana \
    admin_password="$grafana_admin_password" > /dev/null

bao kv put -mount=secret pve_exporter \
    token_value="$pve_exporter_token_value" > /dev/null

echo "[SUCCESS] Opération terminée. Tous les secrets ont été injectés."
echo "quelques tests qu'on fait à la fin, commenter pour désactiver"
bao secrets list 
for secret_path in komodo proxmox-gitops cloudflared authentik grafana pve_exporter; do
    bao kv metadata get -mount=secret "$secret_path" > /dev/null
    echo "[SUCCESS] secret/$secret_path"
done
echo "si ca ne va pas, regardez dans l'ui à $BAO_ADDR"
