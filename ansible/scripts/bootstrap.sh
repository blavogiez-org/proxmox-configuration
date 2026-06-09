#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(dirname "$0")

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
  -i "$SCRIPT_DIR/../inventories/inventory_boostrap.yml" \
  "$SCRIPT_DIR/../playbooks/bootstrap.yml" $@
