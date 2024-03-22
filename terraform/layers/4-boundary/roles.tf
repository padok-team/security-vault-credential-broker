#############
### ROLES ###
#############

resource "boundary_role" "global_anon_listing" {
  scope_id    = boundary_scope.org.id
  name        = "global_anon_listing"
  description = "Global Anon Admin"
  grant_strings = [
    "ids=*;type=auth-method;actions=list,authenticate",
    "ids=*;type=scope;actions=list,no-op",
    "ids={{.Account.Id}};actions=read,change-password"
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
    "ids=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_group.admin.id
  ]
}

resource "boundary_role" "global_project_admin" {
  scope_id    = boundary_scope.org.id
  grant_scope_id = boundary_scope.project.id
  name        = "global_project_admin"
  description = "Global Project Admin"
  grant_strings = [
    "ids=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_group.admin.id
  ]
}

resource "boundary_role" "project_ops" {
  scope_id    = boundary_scope.org.id
  grant_scope_id = boundary_scope.project.id
  name        = "project_ops"
  description = "Project Ops"
  grant_strings = [
    "ids=${boundary_target.ops.id};actions=authorize-session",
    "ids=*;type=target;actions=list"  
  ]
  principal_ids = [
    boundary_group.ops.id
  ]
}


resource "boundary_role" "project_dev" {
  scope_id    = boundary_scope.org.id
  grant_scope_id = boundary_scope.project.id
  name        = "project_dev"
  description = "Project Dev"
  grant_strings = [
    "ids=${boundary_target.dev.id};actions=authorize-session",
    "ids=*;type=target;actions=list"
  ]
  principal_ids = [
    boundary_group.dev.id
  ]
}