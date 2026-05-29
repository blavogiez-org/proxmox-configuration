# Configuration d'une infrastructure Proxmox

## Informations de développement

**Réalisé par** : Baptiste Lavogiez  
**Contact** :  
- Mail : [baptiste.lavogiez@proton.me](mailto:baptiste.lavogiez@proton.me)  
- Page GitHub : [blavogiez](https://github.com/blavogiez) 

## Présentation

Après avoir utilisé AWS, j'auto-héberge désormais tous mes projets (*.blavogiez.fr) sur une infrastructure locale, principalement pour des raisons de coûts à long terme.

En effet, j'ai converti un ancien PC en serveur Proxmox.

Exemple de projet hébergé :
 - https://openlatex.blavogiez.fr | https://openlatex-api.blavogiez.fr/grafana/dashboards

## Modèle

L'objectif de ce dépôt est de centraliser toute la configuration du serveur en une source de vérité unique, soit une approche inspirée du *GitOps*. 

### Automatisations

Le projet est encore à ses débuts (au 14 mai 2026) et voici ce que j'ai pu faire jusqu'ici.
Mes principaux cas d'usage ayant été la migration de [mon projet OpenLaTeX](https://github.com/OpenLaTeX/openlatex.github.io) et la migration de mes autres sites.

#### Déploiement de site

Dans n'importe quel projet, le fichier `domains_deployment.yml` placé à la racine, couplé à [l'action CI/CD réutilisable](.github/workflows/frontend-deploy-website.yml) de déploiement, déclenchera un déploiement automatique de site (HTML / Vite) sur le serveur, plus précisément sur une CT / LXC (une virtualisation allégée) avec Caddy (un reverse proxy).


*Exemple de configuration :*
```yaml
rate_limit: 300

websites:
  - path: websites/deploy/test.blavogiez.fr
    type: html
    referenced: true
    domains: 
      - test.blavogiez.fr
      - health.blavogiez.fr

  - path: websites/deploy/admin.blavogiez.fr
    type: vite
    referenced: false
    domains:
      - admin.blavogiez.fr
    rate_limit: 60
```

*Exemple d'appel de la CI/CD réutilisable :*

```yaml
name: Appel d'un déploiement front

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    uses: blavogiez/proxmox-configuration/.github/workflows/frontend-deploy-website.yml@main
    secrets:
      FRONT_SSH_KEY: ${{ secrets.FRONT_SSH_KEY }}
      FRONT_HOST: ${{ secrets.FRONT_HOST }}
      FRONT_USER: ${{ secrets.FRONT_USER }}
```

Le runner clone le dépôt appelant, puis execute [un script Python de déploiement](websites/deploy_all.py), qui lira la configuration racine (`domains_deployment.yml`) du dépôt cloné, pour appeler [un playbook Ansible de déploiement](ansible/playbooks/deploy-websites.yml) avec tous les sites décrits par la configuration.

Ce playbook recrée les sites dans `/var/www`, les build si besoin (si c'est un site Vite) et recrée le dossier Caddy du dépôt appelant dans `/etc/caddy/sites/<owner__repo>`. Chaque website produit un fichier `.caddy` contenant tous ses domaines. Caddy est lancé via Docker Compose avec une image locale incluant le plugin de rate limit.

Ainsi, le site est déployé en moins de 30 secondes sur une CI/CD et une configuration très minimale.

*La configuration Caddy principale reste stable :*
```caddyfile
{
    auto_https off

    servers {
        trusted_proxies static private_ranges
        trusted_proxies_strict
        client_ip_headers CF-Connecting-IP X-Forwarded-For
    }
}

(site_rate_limit) {
    rate_limit {
        zone {args[0]} {
            key {client_ip}
            events {args[1]}
            window 1m
            ipv6_prefix 64
        }
    }
}

import sites/*/*.caddy
```

*Chaque site a ensuite son propre fragment :*
```caddyfile
# /etc/caddy/sites/blavogiez__mon-depot/test.blavogiez.fr.caddy
http://test.blavogiez.fr, http://health.blavogiez.fr {
    route {
        import site_rate_limit test_blavogiez_fr 300
        root * /var/www/test.blavogiez.fr
        try_files {path} /index.html
        file_server
    }
}
```

Concrètement, cette configuration permet d'avoir une exposition internet gratuite, sans aucune gestion de certificats (grâce à Caddy), avec une configuration minimale, étant très utile pour des projets de groupe.

Le site https://portal.blavogiez.fr est mis à jour à chaque nouveau déploiement quand `referenced: true` est défini pour le site. Le bloc de portail est géré par dépôt appelant, donc retirer un site du YAML retire aussi son entrée au prochain déploiement.

Le `rate_limit` global est appliqué à tous les sites. Sa valeur correspond au nombre de requêtes par minute et par IP. Un site peut définir son propre `rate_limit`, ou le désactiver avec `rate_limit: false`.

##### Améliorations

**Quelques idées d'améliorations quand j'aurai du temps**

Empêcher explicitement le déploiement d'un site si son domaine est déjà présent dans les fragments Caddy d'un autre dépôt. Aujourd'hui, les doublons dans le même YAML sont refusés et les collisions globales sont détectées par `caddy validate`.

#### Création de ressources

Le provider [bpg-proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) est installé sur le serveur et permet de créer des ressources, en l'occurence principalement des VMs / LXC. Dans mon cas, c'est en utilisant Debian 13 Trixie. 


Le dossier [terraform](terraform) les décrit.

À titre d'exemple, j'ai [principalement utilisé ce provider lorsque j'ai migré l'infrastructure de mon projet OpenLaTeX](https://github.com/OpenLaTeX/openlatex.github.io/tree/global-release/infra/terraform/proxmox).
C'est un exemple typique, avec 4 instances dont un cluster Kubernetes. La liaison master / worker se fait au cloud-init.

##### Améliorations

J'aimerais réaliser une gestion de state remote, qui serait pratique car je ne suis pas toujours sur ma machine principale.

Dans la même idée pourquoi pas ajouter un Vault (ou autre) pour avoir une gestion fluide des secrets.

Pour une pleine approche GitOps, j'aimerais aussi ajouter Drift (même si je change rien sur le Gui) pour Terraform.

#### Ressources utiles

Quelques ressources qui m'ont fait gagner du temps :

- [Documentation bpg-proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Helper Scripts Proxmox](https://github.com/community-scripts/ProxmoxVE)
- [Caddyfile import](https://caddyserver.com/docs/caddyfile/directives/import)
- [Ansible Template](https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/template_module.html)
- [Ansible Blockinfile](https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/blockinfile_module.html)
