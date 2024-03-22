#  Postgres Host

resource "boundary_host_catalog_static" "this" {
  name        = "Catalog"
  description = "padoxx catalog"
  scope_id    = boundary_scope.project.id
}


resource "boundary_host" "database" {
  type            = "static"
  name            = "padoxx database"
  description     = "PostgreSQL database"
  address         = data.terraform_remote_state.backbone.outputs.rds.this.address
  host_catalog_id = boundary_host_catalog_static.this.id
}

resource "boundary_host_set" "database" {
  host_catalog_id = boundary_host_catalog_static.this.id
  type            = "static"
  host_ids = [
    boundary_host.database.id,
  ]
}

# Targets

resource "boundary_target" "ops" {
  scope_id     = boundary_scope.project.id
  name         = "database_ops"
  type         = "tcp"
  default_port = "5432"
  session_connection_limit = 1
  host_source_ids = [boundary_host_set.database.id]
  brokered_credential_source_ids = [
    boundary_credential_library_vault.ops.id
  ]
}

resource "boundary_target" "dev" {
  scope_id     = boundary_scope.project.id
  name         = "database_dev"
  type         = "tcp"
  default_port = "5432"
  session_connection_limit = 1
  host_source_ids = [boundary_host_set.database.id]
  brokered_credential_source_ids = [
    boundary_credential_library_vault.dev.id
  ]
}