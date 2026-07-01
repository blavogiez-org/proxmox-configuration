# On va chercher les mots de passe dans OpenBao avant de lancer les VMs

data "vault_generic_secret" "cloudflared_secrets" {
  path = "secret/data/cloudflared/config"
}

data "vault_generic_secret" "authentik_secrets" {
  path = "secret/data/authentik/config"
}