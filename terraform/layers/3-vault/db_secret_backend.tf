resource "vault_mount" "db" {
  path = "postgres"
  type = "database"
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.db.path
  name          = "postgres"
  allowed_roles = ["dev", "ops"]
  plugin_name   = "postgresql-database-plugin"

  postgresql {
    connection_url = "postgresql://${data.terraform_remote_state.backbone.outputs.rds.this.username}:${data.terraform_remote_state.backbone.outputs.rds.this.password}@${data.terraform_remote_state.backbone.outputs.rds.this.address}:5432/postgres"
    username       = "vault"
    password       = "vault-password"
  }
}

resource "vault_database_secret_backend_role" "dev" {
  backend             = vault_mount.db.path
  name                = "dev"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' inherit; grant dev to \"{{name}}\";"]
}

resource "vault_database_secret_backend_role" "ops" {
  backend             = vault_mount.db.path
  name                = "ops"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' inherit; grant ops to \"{{name}}\";"]
}
