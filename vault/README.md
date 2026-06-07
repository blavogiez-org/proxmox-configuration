# Gestion des secrets avec OpenBao

Une VM dédiée contient OpenBao derrière Caddy.
Cette documentation explique comment la configuration est faite, comment créer des secrets KV, comment les récupérer dans GitHub Actions avec AppRole, et comment diagnostiquer les erreurs possibles.

OpenBao peut être exposé sur :

```bash
https://vault.blavogiez.fr
```

Caddy termine le TLS en HTTPS, puis reverse proxy vers OpenBao sur le réseau Docker interne.

Le flow actuel est :

```text
GitHub Actions
-> AppRole OpenBao
-> token temporaire
-> lecture du secret KV secret/data/proxmox/ci
-> export en variables d'environnement
-> utilisation par le job
```

## Principee général

Il y a 3 objets importants dans OpenBao :

| Objet          | Nom actuel               | Utilité                                        |
| -------------- | ------------------------ | ---------------------------------------------- |
| Secrets engine | `secret/`                | moteur KV v2 qui stocke les secrets            |
| Secret KV      | `secret/proxmox/ci`      | paquet de variables utilisé par GitHub Actions |
| Policy         | `proxmox-ci-read`        | autorise uniquement la lecture du secret CI    |
| AppRole        | `github-actions-proxmox` | permet à GitHub Actions de s'authentifier      |

Le secret utilisé par GitHub Actions est :

```bash
secret/proxmox/ci
```

Mais attention, avec KV v2 il y a deux syntaxes :

```bash
# syntaxe CLI
secret/proxmox/ci

# syntaxe API / policy / GitHub Actions
secret/data/proxmox/ci
```

C'est normal, il ne faut pas mélanger les deux.

## exposition OpenBao derrière Caddy

OpenBao est derrière Caddy en Docker Compose.

Le schéma est :

```text
Internet --HTTPS--> Caddy --HTTP Docker interne--> OpenBao
```

Dans ce cas OpenBao peut avoir TLS désactivé côté listener, parce que le TLS public est géré par Caddy. Ca rend la gestion des certs plus simple

Exemple de listener OpenBao :

```hcl
ui = true

api_addr = "https://vault.blavogiez.fr"

storage "raft" {
  path    = "/openbao/data"
  node_id = "openbao-1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}
```

Le point important est que le port OpenBao ne doit pas être publié sur l'hôte.

Dans le `docker-compose.yml`, OpenBao doit ressembler à ça :

```yaml
openbao:
  expose:
    - "8200"
  # surtout pas:
  # ports:
  #   - "8200:8200"
```

Caddy est le seul service qui doit avoir des ports publics :

```yaml
caddy:
  ports:
    - "80:80"
    - "443:443"
```

La config Caddy est simple :

```caddyfile
vault.blavogiez.fr {
  reverse_proxy openbao:8200
}
```

Pour vérifier que le port OpenBao n'est pas exposé publiquement :

```bash
nc -vz vault.blavogiez.fr 8200
```

Il faut que ça échoue.

Pour vérifier que le HTTPS public marche :

```bash
curl -I https://vault.blavogiez.fr
curl -I http://vault.blavogiez.fr
```

Le HTTP doit rediriger vers HTTPS.

## création du moteur KV

Le moteur KV est monté sur `secret/`.

Pour vérifier les secrets engines :

```bash
bao secrets list
```

On doit voir :

```text
secret/    kv
```

Si le moteur n'existe pas encore :

```bash
bao secrets enable -path=secret kv-v2
```

Si la commande renvoie :

```bash
path is already in use
```

c'est que le moteur existe déjà, donc c'est bon.

## Création du secret proxmox/ci

Pour créer ou recréer le secret CI :

```bash
bao kv put -mount=secret proxmox/ci \
  CADDY_SSH_KEY="$(cat ~/.ssh/id_ed25519_caddy)"
```

on peut aussi tagger un fichier avec "@" (CADDY_SSH_KEY=@mykey) !

La commande veut dire :

```text
mount KV: secret/
path: proxmox/ci
```

Donc le vrai chemin API devient :

```text
secret/data/proxmox/ci
```

Il ne faut pas faire :

```bash
bao kv put -mount=secret secret/proxmox/ci ...
```

Sinon ça crée un secret au mauvais endroit :

```text
secret/data/secret/proxmox/ci
```

Pour vérifier le secret :

```bash
bao kv get -mount=secret proxmox/ci
```

ou :

```bash
bao kv get secret/proxmox/ci
```

## Modifier un secret sans tout écraser

Attention, `bao kv put` remplace tout le contenu du secret.

Exemple :

```bash
bao kv put -mount=secret proxmox/ci CADDY_SSH_KEY=tintin
bao kv put -mount=secret proxmox/ci CADDY_SSH_KEYZ=zozo
```

Après la deuxième commande, le secret ne contient plus que :

```text
CADDY_SSH_KEYZ=zozo
```

Pour ajouter ou modifier une seule clé sans supprimer les autres, il faut utiliser `patch` :

```bash
bao kv patch -mount=secret proxmox/ci CADDY_SSH_KEYZ=zozo
```

Règle simple :

```bash
# remplace tout le secret
bao kv put -mount=secret proxmox/ci KEY=value

# ajoute/modifie seulement les clés données
bao kv patch -mount=secret proxmox/ci KEY=value
```

Si une mauvaise version a été créée, on peut rollback :

```bash
bao kv rollback -mount=secret -version=2 proxmox/ci
```

## Création de la policy GitHub Actions

La policy GitHub Actions doit seulement autoriser la lecture du secret CI.

```bash
bao policy write proxmox-ci-read - <<'EOF'
path "secret/data/proxmox/ci" {
  capabilities = ["read"]
}
EOF
```

On vérifie :

```bash
bao policy read proxmox-ci-read
```

Il faut voir :

```hcl
path "secret/data/proxmox/ci" {
  capabilities = ["read"]
}
```

On ne met pas `create`, `update` ou `delete` dans cette policy.
GitHub Actions doit lire les secrets, pas les administrer.

## activation AppRole

Dans l'UI OpenBao, on peut activer AppRole :

```text
Access -> Auth Methods -> Enable new method -> AppRole
```

Path :

```text
approle
```

Par contre l'UI OpenBao ne permet pas de gérer les rôles AppRole.
Elle affiche ce message :

```text
The OpenBao UI only supports configuration for this authentication method.
For management, the API or CLI should be used.
```

Donc la création du rôle se fait en CLI.

Si AppRole n'est pas encore activé :

```bash
bao auth enable approle
```

Si ça répond :

```bash
path is already in use at approle/
```

c'est que AppRole est déjà activé, donc c'est bon.

## création du rôle AppRole

Le rôle utilisé pour GitHub Actions est :

```bash
github-actions-proxmox
```

Commande de création :

```bash
bao write auth/approle/role/github-actions-proxmox \
  token_policies="proxmox-ci-read" \
  token_ttl="15m" \
  token_max_ttl="1h" \
  bind_secret_id=true \
  secret_id_ttl=0 \
  secret_id_num_uses=0 \
  token_num_uses=0
```

Explication rapide :

| Option                 | Utilité                                       |
| ---------------------- | --------------------------------------------- |
| `token_policies`       | policy attachée au token généré               |
| `token_ttl`            | durée de vie initiale du token GitHub Actions |
| `token_max_ttl`        | durée de vie maximale du token                |
| `bind_secret_id=true`  | oblige à utiliser `role_id` + `secret_id`     |
| `secret_id_ttl=0`      | le SecretID n'expire pas                      |
| `secret_id_num_uses=0` | le SecretID peut être utilisé plusieurs fois  |
| `token_num_uses=0`     | le token généré peut faire plusieurs requêtes |

Pour vérifier le rôle :

```bash
bao read auth/approle/role/github-actions-proxmox
```

On doit voir :

```text
token_policies    [proxmox-ci-read]
bind_secret_id    true
token_ttl         15m
token_max_ttl     1h
```

## récupération du role_id et secret_id

Récupérer le `role_id` :

```bash
bao read -field=role_id auth/approle/role/github-actions-proxmox/role-id
```

Générer un `secret_id` :

```bash
bao write -f -field=secret_id auth/approle/role/github-actions-proxmox/secret-id
```

Le `role_id` peut être stocké dans GitHub Secrets.
Le `secret_id` aussi, mais lui est vraiment secret.

Dans GitHub :

```text
Settings
-> Secrets and variables
-> Actions
```

Créer :

```text
VAULT_ROLE_ID=<role_id>
VAULT_SECRET_ID=<secret_id>
```

Ne jamais mettre le root token OpenBao dans GitHub.

## test local de l'AppRole

Pour vérifier que l'AppRole fonctionne :

```bash
export ROLE_ID="<role_id>"
export SECRET_ID="<secret_id>"

APP_TOKEN="$(
  bao write -field=token auth/approle/login \
    role_id="$ROLE_ID" \
    secret_id="$SECRET_ID"
)"
```

Si ça retourne un token, l'AppRole marche.

Pour vérifier les policies du token :

```bash
VAULT_TOKEN="$APP_TOKEN" bao token lookup
```

On doit voir :

```text
policies    [default proxmox-ci-read]
```

Pour vérifier les capabilities :

```bash
VAULT_TOKEN="$APP_TOKEN" bao token capabilities secret/data/proxmox/ci
```

On veut voir :

```text
read
```

Sur un autre path :

```bash
VAULT_TOKEN="$APP_TOKEN" bao token capabilities secret/data/proxmox/other
```

On veut voir :

```text
deny
```

Pour tester la lecture réelle :

```bash
VAULT_TOKEN="$APP_TOKEN" bao kv get -mount=secret proxmox/ci
```

## GitHub Actions

Le job GitHub Actions utilise `hashicorp/vault-action` pour récupérer les secrets OpenBao et les injecter en variables d'environnement.

Exemple :

```yaml
deploy-websites:
  runs-on: self-hosted

  steps:
    - name: Import OpenBao secrets
      uses: hashicorp/vault-action@v4
      with:
        url: https://vault.blavogiez.fr
        method: approle
        roleId: ${{ secrets.VAULT_ROLE_ID }}
        secretId: ${{ secrets.VAULT_SECRET_ID }}
        secrets: |
          secret/data/proxmox/ci * ;

    - name: Start SSH agent
      uses: webfactory/ssh-agent@v0.9.0
      with:
        ssh-private-key: ${{ env.CADDY_SSH_KEY }}
        log-public-key: false

    - name: Deploy
      run: |
        ssh -o StrictHostKeyChecking=accept-new user@serveur 'echo ok'
```

Le bloc :

```yaml
secrets: |
  secret/data/proxmox/ci * ;
```

veut dire :

```text
Lis toutes les clés du secret secret/data/proxmox/ci
et expose-les comme variables d'environnement
```

Donc si le secret contient :

```text
CADDY_SSH_KEY=...
```

alors le job peut utiliser :

```bash
$CADDY_SSH_KEY
```

ou côté YAML :

```yaml
${{ env.CADDY_SSH_KEY }}
```

## Debug GitHub Actions

Pour vérifier que le secret est bien chargé sans l'afficher :

```yaml
- name: Check OpenBao secrets loaded
  run: |
    test -n "$CADDY_SSH_KEY"
    echo "CADDY_SSH_KEY loaded"
```

Il ne faut pas faire :

```bash
echo "$CADDY_SSH_KEY"
```

parce que ça pourrait afficher la clé privée SSH dans les logs.

Si `webfactory/ssh-agent` affiche :

```text
Key(s) added:
256 SHA256:xxxx terraform (ED25519)
```

ce n'est pas la clé privée.
C'est seulement l'empreinte publique de la clé, son type, et son commentaire.

Ce n'est pas un secret critique, donc pas besoin de rotate la clé juste pour ça.

Par contre, si les logs affichent :

```text
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

là il faut considérer la clé comme leakée et la remplacer.

## Erreurs déjà vues

### `path is already in use at approle/`

Erreur :

```bash
bao auth enable approle
```

Retour :

```text
path is already in use at approle/
```

Ca veut dire que AppRole est déjà activé.
Ce n'est pas une erreur bloquante.

### `preflight capability check returned 403`

Erreur vue :

```bash
bao kv put -mount=secret proxmox/ci CADDY_SSH_KEY=tintin
```

Retour :

```text
preflight capability check returned 403
```

Ca veut souvent dire que le token utilisé n'a pas les droits nécessaires.

Commandes utiles :

```bash
echo "$VAULT_ADDR"
echo "$VAULT_TOKEN" | cut -c1-12
bao token lookup
```

Si le token a seulement :

```text
proxmox-ci-read
```

c'est normal que l'écriture fail.
Cette policy est read-only et sert à GitHub Actions.

Pour écrire/modifier les secrets, utiliser un token admin/root depuis la machine d'administration, pas le token AppRole.

### UNe confusion avec `-mount=secret`

Mauvaise commande :

```bash
bao kv put -mount=secret secret/proxmox/ci CADDY_SSH_KEY=zozo
```

Ca écrit ici :

```text
secret/data/secret/proxmox/ci
```

Bonne commande :

```bash
bao kv put -mount=secret proxmox/ci CADDY_SSH_KEY=zozo
```

Ca écrit ici :

```text
secret/data/proxmox/ci
```

### `put` a supprimé les anciennes clés

Si on fait :

```bash
bao kv put -mount=secret proxmox/ci CADDY_SSH_KEY=tintin
bao kv put -mount=secret proxmox/ci CADDY_SSH_KEYZ=zozo
```

Alors la deuxième commande remplace tout le secret.

Pour ajouter une clé :

```bash
bao kv patch -mount=secret proxmox/ci CADDY_SSH_KEYZ=zozo
```

Pour revenir à une ancienne version :

```bash
bao kv rollback -mount=secret -version=2 proxmox/ci
```

## commandes utiles

Lister les secrets engines :

```bash
bao secrets list
```

Lire le secret CI :

```bash
bao kv get -mount=secret proxmox/ci
```

Créer/recréer le secret CI :

```bash
bao kv put -mount=secret proxmox/ci \
  CADDY_SSH_KEY="$(cat ~/.ssh/id_ed25519_caddy)"
```

Ajouter une variable sans supprimer les autres :

```bash
bao kv patch -mount=secret proxmox/ci NOM_VARIABLE="valeur"
```

Lire la policy :

```bash
bao policy read proxmox-ci-read
```

Lire le rôle AppRole :

```bash
bao read auth/approle/role/github-actions-proxmox
```

Récupérer le RoleID :

```bash
bao read -field=role_id auth/approle/role/github-actions-proxmox/role-id
```

Générer un nouveau SecretID :

```bash
bao write -f -field=secret_id auth/approle/role/github-actions-proxmox/secret-id
```

Tester le login AppRole :

```bash
bao write auth/approle/login \
  role_id="$VAULT_ROLE_ID" \
  secret_id="$VAULT_SECRET_ID"
```

## démonstration

Ici, GitHub Actions récupère les secrets depuis OpenBao avec AppRole, puis charge la clé SSH dans `ssh-agent`.

La chaîne complète est :

```text
GitHub Secrets
VAULT_ROLE_ID + VAULT_SECRET_ID

-> OpenBao AppRole github-actions-proxmox
-> policy proxmox-ci-read
-> secret/data/proxmox/ci
-> variable d'environnement CADDY_SSH_KEY
-> webfactory/ssh-agent
-> déploiement SSH
```

Si le step suivant passe :

```yaml
- name: Check OpenBao secrets loaded
  run: |
    test -n "$CADDY_SSH_KEY"
    echo "CADDY_SSH_KEY loaded"
```

alors l'intégration OpenBao -> GitHub Actions fonctionne bien.
