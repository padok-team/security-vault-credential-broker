resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_token" "boundary" {

  no_default_policy = true
  policies          = ["boundary-controller", "database"]

  renewable = true
  period    = "20m"
  ttl       = "24h"
  no_parent = true

  metadata = {
    "purpose" = "boundary"
  }
}
