resource "vault_policy" "admin" {
  name = "admin"

  policy = <<EOF
# Read system health check
path "sys/health"
{
  capabilities = ["read", "sudo"]
}

# Create and manage ACL policies broadly across Vault

# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Enable and manage authentication methods broadly across Vault

# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# Enable and manage the key/value secrets engine at `secret/` path

# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read"]
}

path "postgres/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "postgres"
{
  capabilities = ["read"]
}

EOF
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

resource "vault_policy" "database" {
  name = "database"

  policy = <<EOT
path "postgres/creds/dev" {
  capabilities = ["read"]
}

path "postgres/creds/ops" {
  capabilities = ["read"]
}
EOT
}

resource "vault_policy" "database_dev" {
  name = "database_dev"

  policy = <<EOT
path "postgres/creds/dev" {
  capabilities = ["read"]
}
EOT
}

resource "vault_policy" "database_ops" {
  name = "database_ops"

  policy = <<EOT
path "postgres/creds/ops" {
  capabilities = ["read"]
}
EOT
}

