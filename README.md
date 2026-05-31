# Configuration d'une infrastructure Proxmox

## Informations de développement

Ce projet est développé et maintenu par **Baptiste Lavogiez** et **Jonas Facon**, avec pour objectif de proposer une infrastructure serveur fiable, automatisée et reproductible autour de Proxmox VE.

Ce dépôt a vocation à être la source commune de nos infrastructures Proxmox personnelles (templates, outils d'administration type VPN...). Puisqu'ayant chacun un serveur avec des besoins différents, ce dépôt sera forké.

Nous privilégierons une approche Infrastructure as Code et similaire aux principes GitOps.

### Réalisé par

| Auteur            | Email                                                             | GitHub                                                           |
| ----------------- | ----------------------------------------------------------------- | ---------------------------------------------------------------- |
| Baptiste Lavogiez | [baptiste.lavogiez@proton.me](mailto:baptiste.lavogiez@proton.me) | [blavogiez](https://github.com/blavogiez) |
| Jonas Facon       | [jonas.facon@proton.me](mailto:jonas.facon@proton.me)             | [Jonas0o0](https://github.com/Jonas0o0)   |

## Conventions de développement

Puisqu'il s'agit d'un projet commun, nous avons défini quelques règles :
- 


## Présentation

L’objectif de ce projet est de concevoir un serveur Proxmox VE clé en main.
Il est pensé pour fournir une base solide regroupant les services essentiels dont tout serveur a besoin, comme un VPN, un reverse proxy, ainsi qu’une configuration sécurisée et fiable.
Cela inclut notamment le chiffrement des disques, les sauvegardes automatiques et la gestion de réseaux virtuels.

## Approche GitOps

Le projet repose sur une approche GitOps : le dépôt Git constitue la source de vérité de l’infrastructure.

Ainsi, chaque modification validée sur la branche `main` déclenche automatiquement la mise à jour des serveurs, garantissant une configuration cohérente, versionnée et reproductible.
