#############
### USERS ###
#############

resource "boundary_account_password" "thibault" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "thibaultl"
  password       = "$uper$ecure"
}

resource "boundary_user" "thibault" {
  scope_id    = boundary_scope.org.id
  account_ids = [boundary_account_password.thibault.id]
  name        = "Thibault"
  description = "Thibault's user resource"
}

resource "boundary_account_password" "clement" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "clementfa"
  password       = "$uper$ecure"
}

resource "boundary_user" "clement" {
  scope_id    = boundary_scope.org.id
  account_ids = [boundary_account_password.clement.id]
  name        = "Clément"
  description = "Clément's user resource"
}

resource "boundary_account_password" "josephine" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "josephines"
  password       = "$uper$ecure"
}

resource "boundary_user" "josephine" {
  scope_id    = boundary_scope.org.id
  account_ids = [boundary_account_password.josephine.id]
  name        = "Joséphine"
  description = "Joséphine's user resource"
}