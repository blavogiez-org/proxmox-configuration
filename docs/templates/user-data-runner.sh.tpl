#cloud-config
users:
  - name: admin
    groups: docker
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_public_key}
packages:
  - qemu-guest-agent
  - libicu76
  - git
  - curl 
  - pip 
  - pipx 
  - gpg
  - python3
runcmd: 
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - curl -fsSl https://get.docker.com | sh