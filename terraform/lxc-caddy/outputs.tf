output "caddy_ssh" {
  description = "ssh vers le CT Caddy"
  value       = "ssh -t root@${var.caddy_ip}"
}
