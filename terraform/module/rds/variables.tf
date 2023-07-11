# ================================[ General ]===============================

variable "availability_zone" {
  description = "Availability zone to use when Multi AZ is disabled"
  type        = string
  default     = "eu-west-3a"
}

# =============================[ RDS Instance  ]=============================

variable "identifier" {
  description = "Unique identifier for your RDS instance. For example, aws_rds_instance_postgres_poc_library_break"
  type        = string
}

variable "instance_class" {
  description = "Instance class for your RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage allocated to your RDS instance in Gigabytes"
  type        = number
  default     = 10
}

variable "engine" {
  description = "Engine used for your RDS instance (mysql, postgres ...)"
  type        = string
}

variable "engine_version" {
  description = "Version of your engine"
  type        = string
}

variable "multi_az" {
  description = "Set to true to deploy a multi AZ RDS instance"
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Set to true to enable performance insights on your RDS instance"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of your database in your RDS instance"
  type        = string
  default     = "aws_padok_database_instance"
}

variable "username" {
  description = "Name of the master user for the database in your RDS Instance"
  type        = string
  default     = "admin"
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period"
  type        = number
  default     = 30
}

variable "port" {
  description = "The port on which the DB accepts connections. Default is chosen depeding on the engine"
  type        = number
  default     = null
}

variable "apply_immediately" {
  description = "Specifies if database modifications should be applied immediately, or during the next maintenance window"
  type        = bool
  default     = false
}

variable "max_allocated_storage" {
  description = "When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance"
  type        = number
  default     = 50
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs to create your db subnet group"
  type        = list(string)
}

variable "rds_skip_final_snapshot" {
  description = "If set to true, a final DB snapshot will be created before the DB instance is deleted"
  type        = bool
  default     = false
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)"
  type        = string
  default     = "gp2"
}

variable "publicly_accessible" {
  description = "Boolean to control if instance is publicly accessible."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "Security group IDs allowed to connect to the RDS Instance"
  type        = list(string)
  default     = []
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether or not mappings of AWS Identity and Access Management (IAM) accounts to database accounts are enabled"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "ID of the VPC to deploy the database to"
  type        = string
}

# ===========================[ RDS parameter group]========================

variable "db_parameter_family" {
  description = "The family of the DB parameter group. Should be one of: postgres11, postgres12, postgres13, mysql5.6, mysql5.7, mysql8.0 for MySQL or Postgres"
  type        = string
}

variable "parameters" {
  description = "List of paramaters to add to the database"
  type = list(object({
    name         = string
    value        = string
    apply_method = string
  }))
  default = []
}

# ===========================[ Use existing Encryption key ]========================

variable "arn_custom_kms_key" {
  description = "Arn of your custom KMS Key. Useful only if custom_kms_key is set to true"
  type        = string
  default     = null
}

# ===========================[ RDS Secret settings]========================

variable "rds_secret_recovery_window_in_days" {
  description = "Secret recovery window in days"
  type        = number
  default     = 10
}

variable "force_ssl" {
  description = "Force SSL for DB connections, only works with Postgres engine"
  type        = string
  default     = true
}

variable "arn_custom_kms_key_secret" {
  description = "Encrypt AWS secret with CMK"
  type        = string
  default     = null
}

variable "password_length" {
  description = "Password length for db master user, Minimum length is 25"
  type        = number
  default     = 40
}
