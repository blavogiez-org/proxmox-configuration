# Configuration d'une infrastructure Proxmox

**Fork personnalisé à une base commune développée avec Jonas Facon, camarade de BUT.**

## Informations de développement

La base commune est développée et maintenue par **Baptiste Lavogiez** et **Jonas Facon**, avec pour objectif de proposer une infrastructure serveur fiable, automatisée et reproductible autour de Proxmox VE.

Notre projet commun a vocation à être la source commune de nos infrastructures Proxmox personnelles (templates, outils d'administration type VPN...). Puisqu'ayant chacun un serveur avec des besoins et services différents, ce dépôt est forké par chacun.

En l'occurence, je prévois de déployer des services tels que Kanboard, Nextcloud, Vaultwarden et Uptime Kuma.

Puisque le dépôt doit être public, et pour que les workflows le soient aussi, nous restons sur GitHub par simplicité. 

Ce projet privilégie une approche Infrastructure as Code et similaire aux principes GitOps.

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
