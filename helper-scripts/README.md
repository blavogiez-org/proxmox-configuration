# Scripts de facilitation de la configuration du dépôt

Les scripts présents dans ce dossier ont principalement pour objectif de créer les fichiers de configuration principaux du dépôt de façon simple en demandant à l'utilisateur de les entrer.

Certains secrets alors créés, comme par exemple le token Terraform pour Proxmox sont plus simples à entrer puisque leur complexité est abstraite.
Il s'agit de la même idée pour Vault / OpenBao, où l'utilisateur est invité à saisir des clés / valeurs, pour que leur mise effective dans Vault / OpenBao soit réalisée par le script.

Cela permet une accessibilité plus générale au dépôt, et a pour but de faciliter les migrations et personnalisations, d'autant plus dans notre contexte de projet en binôme devant être opérationnel sur deux machines, avec des paramètres différents.