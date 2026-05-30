#cloud-config
hostname: ${hostname}

users:
  - default
  - name: ${username}
    groups:
      - sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_public_key}
    sudo: ALL=(ALL) NOPASSWD:ALL
