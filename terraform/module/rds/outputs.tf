output "this" {
  description = "RDS Instance"
  value       = aws_db_instance.this
}

output "security_group" {
  description = "Security group of the RDS Instance"
  value       = aws_security_group.this
}