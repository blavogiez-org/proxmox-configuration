#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "$script_dir/../.." && pwd)"
cd "$repo_dir"

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ansible/inventories/inventory.yml ansible/playbooks/deploy_any_compose.yml "$@"
