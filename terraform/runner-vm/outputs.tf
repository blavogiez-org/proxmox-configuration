output "openlatex_runner_ssh_vm" {
  description = "Commande SSH vers la vm Runner"
  value       = "ssh -t -i ~/.ssh/github_deploy_key admin@${try(proxmox_virtual_environment_vm.runner-vm.ipv4_addresses[1][0], "not-ready")}"
}

output "openlatex_runner_ip" {
  value = proxmox_virtual_environment_vm.runner-vm.ipv4_addresses
}