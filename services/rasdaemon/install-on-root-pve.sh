# RASDAEMON vérifie les erreurs mémoires au niveau matériel (), donc ça se met sur l'hôte proxmox
# c'est quand meme un service donc il suit la structure du dépôt
apt update
apt install rasdaemon
systemctl enable --now rasdaemon
ras-mc-ctl --status
ras-mc-ctl --summary