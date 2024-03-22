##############
### GROUPS ###
##############

resource "boundary_group" "admin" {
  name        = "Admin"
  description = "Group for padoxx admin"
  member_ids  = [boundary_user.thibault.id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_group" "ops" {
  name        = "Ops"
  description = "Group for padoxx ops"
  member_ids  = [boundary_user.clement.id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_group" "dev" {
  name        = "Dev"
  description = "Group for padoxx dev"
  member_ids  = [boundary_user.josephine.id]
  scope_id    = boundary_scope.org.id
}