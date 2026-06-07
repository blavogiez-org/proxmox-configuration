#!/usr/bin/env bash
set -euo pipefail

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
  -i inventory_alloy.yml \
  playbooks/install_alloy.yml $@
