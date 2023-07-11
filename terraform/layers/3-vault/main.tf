resource "vault_mount" "db" {
  path = "postgres"
  type = "database"
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.db.path
  name          = "postgres"
  allowed_roles = ["dba", "analyst"]
  plugin_name   = "postgresql-database-plugin"

  postgresql {
    connection_url = "postgresql://${data.terraform_remote_state.backbone.outputs.rds.this.username}:${data.terraform_remote_state.backbone.outputs.rds.this.password}@${data.terraform_remote_state.backbone.outputs.rds.this.address}:5432/postgres"
    username       = "vault"
    password       = "vault-password"
  }
}

resource "vault_policy" "boundary-controller" {
  name = "boundary-controller"

  policy = <<EOT
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/revoke-self" {
  capabilities = ["update"]
}

path "sys/leases/renew" {
  capabilities = ["update"]
}

path "sys/leases/revoke" {
  capabilities = ["update"]
}

path "sys/capabilities-self" {
  capabilities = ["update"]
}
EOT
}

resource "vault_database_secret_backend_role" "dba" {
  backend             = vault_mount.db.path
  name                = "dba"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' inherit; grant northwind_dba to \"{{name}}\";"]
}

resource "vault_database_secret_backend_role" "analyst" {
  backend             = vault_mount.db.path
  name                = "analyst"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' inherit; grant northwind_analyst to \"{{name}}\";"]
}

resource "vault_policy" "northwind-database" {
  name = "northwind-database"

  policy = <<EOT
path "postgres/creds/analyst" {
  capabilities = ["read"]
}

path "postgres/creds/dba" {
  capabilities = ["read"]
}
EOT
}

resource "vault_token" "boundary" {

  no_default_policy = true
  policies          = ["boundary-controller", "northwind-database"]

  renewable = true
  period    = "20m"
  ttl       = "24h"
  no_parent = true

  metadata = {
    "purpose" = "boundary"
  }
}
