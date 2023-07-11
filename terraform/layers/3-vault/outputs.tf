output "vault_token" {
  value       = vault_token.boundary
  description = "Vault token for Boundary credential store"
  sensitive   = true
}
