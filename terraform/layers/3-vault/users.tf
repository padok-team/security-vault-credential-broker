resource "vault_generic_endpoint" "thibault" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/thibaultl"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["admin"],
  "password": "$uper$ecure"
}
EOT
}

resource "vault_generic_endpoint" "clement" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/clementf"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["database_ops"],
  "password": "$uper$ecure"
}
EOT
}

resource "vault_generic_endpoint" "josephine" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/josephines"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["database_dev"],
  "password": "$uper$ecure"
}
EOT
}