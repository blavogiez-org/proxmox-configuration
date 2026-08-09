# services d'administration à protéger
# tout est isolé, le seul trafic autorisé sera de caddy vers leurs ports
locals {
  fork_caddy_backends = {
  }
}

# exemple : 
# locals {
#   fork_caddy_backends = {
#     vaultwarden = {
#       guest_type = "vm"
#       guest_id   = module.vaultwarden.vm_id
#       ports      = ["8000"]
#     }
#     zot = {
#       guest_type = "lxc"
#       guest_id   = module.zot.lxc_id
#       ports      = ["5000"]
#     }
#   }
# }