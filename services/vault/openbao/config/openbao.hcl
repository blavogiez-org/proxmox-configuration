ui = true

storage "file" {
  path = "/openbao/file"
}

# le tls / https est géré par le pointeur caddy du nom de domaine, c'est plus maintenable
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

api_addr = "http://localhost:8200"
