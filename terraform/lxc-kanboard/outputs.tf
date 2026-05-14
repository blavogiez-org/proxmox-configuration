output "kanboard_ssh" {
  description = "ssh vers le CT kanboard"
  value       = "ssh -t root@${var.kanboard_ip}"
}
