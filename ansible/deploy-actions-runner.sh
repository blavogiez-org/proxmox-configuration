#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

read -rp "Runner count: " RUNNER_COUNT
read -rp "Runner names: " RUNNER_NAMES
read -rsp "Runner token: " RUNNER_TOKEN; echo
ANSIBLE_HOST_KEY_CHECKING=False RUNNER_COUNT="$RUNNER_COUNT" RUNNER_NAMES="$RUNNER_NAMES" RUNNER_TOKEN="$RUNNER_TOKEN" ansible-playbook -i inventories/inventory.yml playbooks/deploy-actions-runner.yml
