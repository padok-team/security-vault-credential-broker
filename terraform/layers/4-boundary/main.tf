resource "boundary_scope" "org" {
  scope_id                 = "global"
  name                     = "padok"
  description              = "Padok Org"
  auto_create_default_role = true
  auto_create_admin_role   = true
}

resource "boundary_scope" "project" {
  scope_id                 = boundary_scope.org.id
  name                     = "project"
  description              = "project"
  auto_create_default_role = true
  auto_create_admin_role   = true
}

resource "boundary_auth_method" "password" {
  scope_id = boundary_scope.org.id
  type     = "password"
  name = "my_method"
  description = "My password auth method"
}

resource "boundary_account_password" "jeff" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "jeff"
  password       = "$uper$ecure"
}

resource "boundary_user" "jeff" {
  scope_id    = boundary_scope.org.id
  account_ids = [boundary_account_password.jeff.id]
  name        = "jeff"
  description = "Jeff's user resource"
}

resource "boundary_role" "global_anon_listing" {
  scope_id    = boundary_scope.org.id
  name        = "global_anon_listing"
  description = "Global Anon Admon"
  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "id=*;type=scope;actions=list,no-op",
    "id=${boundary_account_password.jeff.id};actions=read,change-password"
  ]
  principal_ids = [
    "u_anon"
  ]
}

resource "boundary_role" "global_org_admin" {
  scope_id    = boundary_scope.org.id
  name        = "global_org_admin"
  description = "Global Org Admin"
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_user.jeff.id
  ]
}

resource "boundary_role" "global_project_admin" {
  scope_id    = boundary_scope.org.id
  grant_scope_id = boundary_scope.project.id
  name        = "global_project_admin"
  description = "Global Project Admin"
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_user.jeff.id
  ]
}

#  Postgres Host

resource "boundary_host_catalog" "static" {
  name        = "My catalog"
  description = "My first host catalog!"
  type        = "static"
  scope_id    = boundary_scope.project.id
}

resource "boundary_host" "example" {
  type            = "static"
  name            = "example_host"
  description     = "My first host!"
  address         = data.terraform_remote_state.backbone.outputs.rds.this.address
  host_catalog_id = boundary_host_catalog.static.id
}

resource "boundary_host_set" "example" {
  host_catalog_id = boundary_host_catalog.static.id
  type            = "static"
  host_ids = [
    boundary_host.example.id,
  ]
}

# Targets

resource "boundary_target" "northwind_analyst" {
  scope_id     = boundary_scope.project.id
  name         = "Northwind Analyst Database"
  type         = "tcp"
  default_port = "5432"
  session_connection_limit = 1
  host_source_ids = [boundary_host_set.example.id]
  brokered_credential_source_ids = [
    boundary_credential_library_vault.analyst.id
  ]
}

resource "boundary_target" "northwind_dba" {
  scope_id     = boundary_scope.project.id
  name         = "Northwind DBA Database"
  type         = "tcp"
  default_port = "5432"
  session_connection_limit = 1
  host_source_ids = [boundary_host_set.example.id]
  brokered_credential_source_ids = [
    boundary_credential_library_vault.dba.id
  ]
}

# Vault credential store

resource "boundary_credential_store_vault" "example" {
  name        = "vault"
  description = "Vault credential store"
  address     = "http://vault.vault.svc.cluster.local:8200"
  token       = data.terraform_remote_state.vault.outputs.vault_token.client_token
  scope_id    = boundary_scope.project.id
}

# Credential libraries

resource "boundary_credential_library_vault" "dba" {
  name                = "dba"
  description         = "Northwind DBA credential library"
  credential_store_id = boundary_credential_store_vault.example.id
  path                = "postgres/creds/dba"
}

resource "boundary_credential_library_vault" "analyst" {
  name                = "analyst"
  description         = "Northwind DBA credential analyst"
  credential_store_id = boundary_credential_store_vault.example.id
  path                = "postgres/creds/analyst"
}