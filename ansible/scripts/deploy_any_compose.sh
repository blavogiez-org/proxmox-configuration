#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/.."

<<<<<<< HEAD:ansible/scripts/deploy_any_compose.sh
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventories/inventory.yml playbooks/deploy-any-compose.yml
=======
<<<<<<< Updated upstream:ansible/scripts/deploy-caddy.sh
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventories/inventory.yml playbooks/deploy-caddy.yml
=======
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventories/inventory.yml playbooks/deploy_any_compose.yml $@
>>>>>>> Stashed changes:ansible/scripts/deploy_any_compose.sh
>>>>>>> b03e2f2 (feat(vaultwarden): compose templaté J2):ansible/scripts/deploy-caddy.sh
