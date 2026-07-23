# Monitoring

La documentation du monitoring est disponible dans [docs/MONITORING.md](../../docs/MONITORING.md).

# Caddy

Un reverse proxy Caddy est présent pour donner un port précis aux endpoints Prometheus / Loki centralisant toutes les métriques (toutes les VM/LXC écrivent dessus)

Ainsi avec le firewall on peut restreindre l'accès des instances à un seul port de la VM Monitoring centrale

exemple : 

monitoring-proxy:9090/api/v1/write = http://prometheus:9090/api/v1/write 
monitoring-proxy:3100/loki/api/v1/push = http://loki:3100/loki/api/v1/push

on peut alors, au final, faire un firewall par URL (puisqu'ici un port devient restreint à une seule URL), ce qui est particulièrement intéressant puisque Prometheus et Loki sont des sources de secrets (Les logs peuvent contenir des token)

Ainsi on expose uniquement ce dont les agents Alloy ont besoin ; d'écrire sur Prometheus / Loki et jamais de lire