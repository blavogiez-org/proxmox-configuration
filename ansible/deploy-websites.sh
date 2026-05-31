#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
  -i inventories/inventory.yml \
  playbooks/deploy-websites.yml \
  -e "@$CALLER_DIR/domains_deployment.yml" \
  -e "caller_dir=$CALLER_DIR" \
  -e "caller_repository=$CALLER_REPOSITORY"
