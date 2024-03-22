resource "boundary_scope" "org" {
  scope_id                 = "global"
  name                     = "padoxx"
  description              = "padoxx Org"
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
  name = "Password"
  description = "Password auth method"
}