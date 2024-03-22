# Vault credential store

resource "boundary_credential_store_vault" "vault" {
  name        = "vault_credential_store"
  description = "Vault credential store"
  address     = "http://vault.2.aws.padok.cloud"
  token       = data.terraform_remote_state.vault.outputs.vault_token.client_token
  scope_id    = boundary_scope.project.id
}

# Credential libraries

resource "boundary_credential_library_vault" "ops" {
  name                = "ops"
  description         = "Ops credential library"
  credential_store_id = boundary_credential_store_vault.vault.id
  path                = "postgres/creds/ops"
}

resource "boundary_credential_library_vault" "dev" {
  name                = "dev"
  description         = "Dev credential dev"
  credential_store_id = boundary_credential_store_vault.vault.id
  path                = "postgres/creds/dev"
}