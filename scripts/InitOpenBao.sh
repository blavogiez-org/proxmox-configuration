#!/bin/bash
export BAO_ADDR="http://192.168.10.15:8200"

RAW_KEYS_FILE="/tmp/bao_keys_raw.json"
USER_SECRETS_FILE="/tmp/secrets_openbao_utilisateur.txt"

INIT_STATUS=$(bao status -format=json | jq -r '.initialized')

if [ "$INIT_STATUS" == "false" ]; then
    echo "Le serveur OpenBao n'est pas encore initialise."

    read -r -p "Voulez-vous proceder a l'initialisation automatique maintenant ? (o/n) " user_choice

    case "$user_choice" in
        [oO]|[yY]|oui|Oui|yes|Yes)
            echo "Initialisation d'OpenBao en cours..."

            bao operator init -key-shares=5 -key-threshold=3 -format=json > "$RAW_KEYS_FILE"
            chmod 600 "$RAW_KEYS_FILE"

            ROOT_TOKEN=$(jq -r '.root_token' "$RAW_KEYS_FILE")

            echo "===============================================" > "$USER_SECRETS_FILE"
            echo "       IDENTIFIANTS OPENBAO                    " >> "$USER_SECRETS_FILE"
            echo "===============================================" >> "$USER_SECRETS_FILE"
            echo "" >> "$USER_SECRETS_FILE"
            echo "Token Root (Administrateur) :" >> "$USER_SECRETS_FILE"
            echo "$ROOT_TOKEN" >> "$USER_SECRETS_FILE"
            echo "" >> "$USER_SECRETS_FILE"
            echo "Cles de descellement (Unseal Keys) :" >> "$USER_SECRETS_FILE"
            echo "Il faut 3 de ces cles pour deverrouiller le serveur :" >> "$USER_SECRETS_FILE"

            jq -r '.unseal_keys_b64[]' "$RAW_KEYS_FILE" | while read -r key; do
                echo "- $key" >> "$USER_SECRETS_FILE"
            done

            echo "===============================================" >> "$USER_SECRETS_FILE"
            chmod 600 "$USER_SECRETS_FILE"

            echo "OpenBao initialise avec succes."
            echo "Les secrets ont ete generes dans : $USER_SECRETS_FILE"

            echo "Deverrouillage automatique du serveur en cours..."

            # On extrait exactement 3 cles (index 0 a 2) et on les passe a la commande unseal
            jq -r '.unseal_keys_b64[0:3][]' "$RAW_KEYS_FILE" | while read -r key; do
                bao operator unseal "$key" > /dev/null
            done

            echo "Serveur deverrouille avec succes. Il est pret a etre utilise."
            ;;
        *)
            echo "Initialisation annulee par l'utilisateur. Passage a l'etape suivante."
            ;;
    esac
else
    echo "OpenBao est deja initialise."

    # Verification du scellement si le serveur etait deja initialise
    SEALED_STATUS=$(bao status -format=json | jq -r '.sealed')
    if [ "$SEALED_STATUS" == "true" ]; then
        echo "Le serveur est actuellement scelle. Un deverrouillage manuel est requis."
    else
        echo "Le serveur est deja deverrouille."
    fi
fi

export VAULT_TOKEN=$(jq -r '.root_token' /tmp/bao_keys_raw.json)
export VAULT_ADDR="http://192.168.10.15:8200"
