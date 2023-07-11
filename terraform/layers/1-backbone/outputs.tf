output "rds" {
  value = module.rds
  description = "RDS"
  sensitive= true
}

output "kms_id" {
  value = aws_kms_key.recovery.key_id
}