resource "aws_kms_key" "worker_auth" {
  description             = "KMS key for worker authentication"
  deletion_window_in_days = 10
}

resource "aws_kms_key" "root" {
  description             = "KMS key for database encryption"
  deletion_window_in_days = 10
}

resource "aws_kms_key" "recovery" {
  description             = "KMS key for database recovery"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "worker_auth" {
  name          = "alias/${local.name}-worker_auth"
  target_key_id = aws_kms_key.worker_auth.key_id
}

resource "aws_kms_alias" "root" {
  name          = "alias/${local.name}-root"
  target_key_id = aws_kms_key.root.key_id
}

resource "aws_kms_alias" "recovery" {
  name          = "alias/${local.name}-recovery"
  target_key_id = aws_kms_key.recovery.key_id
}