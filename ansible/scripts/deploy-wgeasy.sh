#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/.."

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventories/inventory.yml playbooks/deploy-wgeasy.yml
