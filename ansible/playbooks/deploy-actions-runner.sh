#!/bin/bash
read -rp "Host: " host
read -rp "Runner count: " RUNNER_COUNT
read -rp "Runner names: " RUNNER_NAMES
read -rsp "Runner token: " RUNNER_TOKEN; echo
RUNNER_COUNT="$RUNNER_COUNT" RUNNER_NAMES="$RUNNER_NAMES" RUNNER_TOKEN="$RUNNER_TOKEN" ansible-playbook -i "$host," deploy-actions-runner.yml
