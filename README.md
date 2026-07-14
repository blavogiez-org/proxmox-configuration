# Configuration d'une infrastructure Proxmox

## Informations de développement

La base commune est développée et maintenue par **Baptiste Lavogiez** et **Jonas Facon**, avec pour objectif de proposer une infrastructure serveur fiable, automatisée et reproductible autour de Proxmox VE.

Notre projet commun a vocation à être la source commune de nos infrastructures Proxmox personnelles (templates, outils d'administration type VPN...). Puisqu'ayant chacun un serveur avec des besoins et services différents, ce dépôt est forké par chacun.

Puisque le dépôt doit être public, et pour que les workflows le soient aussi, nous restons sur GitHub par simplicité. 

Ce projet privilégie une approche Infrastructure as Code et similaire aux principes GitOps.

### Réalisé par

| Auteur            | Email                                                             | GitHub                                                           |
| ----------------- | ----------------------------------------------------------------- | ---------------------------------------------------------------- |
| Baptiste Lavogiez | [baptiste.lavogiez@proton.me](mailto:baptiste.lavogiez@proton.me) | [blavogiez](https://github.com/blavogiez) |
| Jonas Facon       | [jonas.facon@proton.me](mailto:jonas.facon@proton.me)             | [Jonas0o0](https://github.com/Jonas0o0)   |

## Présentation

L’objectif de ce projet est de concevoir un serveur Proxmox VE clé en main.
Il est pensé pour fournir une base solide regroupant les services essentiels dont tout serveur a besoin, comme un VPN, un reverse proxy, ainsi qu’une configuration sécurisée et fiable.
Cela inclut notamment le chiffrement des disques, les sauvegardes automatiques et la gestion de réseaux virtuels.

Pour plus de détails sur l'architecture réseau et les composants, consultez la **[Documentation de l'Infrastructure](docs/INFRA.md)**.

## Conventions de développement

Puisqu'il s'agit d'un projet commun, nous définissons ces conventions :
- Limiter le développement par IA afin d'apprendre au mieux, n'utiliser que pour se documenter / review
- Lorsque l'on utilise un nouvel outil, se renseigner rapidement sur les bonnes pratiques
- Appliquer les principes [DRY, KISS, YAGNI](https://scalastic.io/solid-dry-kiss/)
- [Feature branch](https://www.atlassian.com/fr/git/tutorials/comparing-workflows/feature-branch-workflow) et merge requests (à part pour des petits edit / modifications de doc)
- Pour les installations complexes, écrire une documentation / procédure pour que l'autre puisse la reproduire

## Approche GitOps & auto-déploiement

Le projet repose sur une approche GitOps : le dépôt Git constitue la source de vérité de l’infrastructure.

Ainsi, chaque modification validée sur la branche `main` déclenche automatiquement la mise à jour des serveurs, garantissant une configuration cohérente, versionnée et reproductible.

Pour résumer rapidement, les déploiements des services d'administration sont réalisés par playbooks, avec un playbook Ansible pouvant assurer le déploiement de n'importe quel service en argument (grâce à l'arborescence du dépôt avec une logique uniforme). En CI/CD, nous itérons donc sur tous les services déployables et appelons ce playbook.

Ce playbook va :
- obtenir les secrets du Vault, secrets correspondant au service en argument (chemin = nom service) ;
- copier la stack vers l'hôte (même nom que le service), s'agissant d'une VM ou LXC ;
- injecter les variables et secrets dans les templates Jinja2 ;
- redémarrer la stack docker compose si l'ensemble a changé.

Côté GitHub Actions, le système de matrix permet de paralléliser un job sur lequel est itéré une liste, en l'occurrence les services (obtenus par [cette action réutilisable](github.com/philips-labs/list-folder-action))

Ces mises à jour sont appliquées sur les dépôts forks. En voici un exemple : 
<img width="1198" height="596" alt="image" src="https://github.com/user-attachments/assets/1bae44da-15ec-4ae2-846d-1de670e07528" />

[Run correspondant](https://github.com/blavogiez-org/proxmox-configuration/actions/runs/28758799580)
Il n'y a pas toujours de secrets Vault associés au service. Si il n'y en a pas, on met un avertissement.
Pour voir le cas où il y en a un, voir le service `cloudflared` et [son itération](https://github.com/blavogiez-org/proxmox-configuration/actions/runs/28758799580/job/85270533716).