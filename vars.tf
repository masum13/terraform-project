// Common

variable "environment" {
  description = ""
  type        = string
}

variable "project" {
  description = ""
  type        = string
}

variable "tfstate_bucket" {
  description = ""
  type        = string
}

variable "region" {
  description = ""
  type        = string
}

variable "vpc_tags" {
  description = ""
  type        = map(string)
  default     = {}
}

variable "availability_zones" {
  description = ""
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = ""
  type        = string
}

variable "public_subnet_1_cidr" {
  description = ""
  type        = string
}

variable "public_subnet_2_cidr" {
  description = ""
  type        = string
}

variable "public_subnet_3_cidr" {
  description = ""
  type        = string
}

variable "private_subnet_1_cidr" {
  description = ""
  type        = string
}

variable "private_subnet_2_cidr" {
  description = ""
  type        = string
}

variable "private_subnet_3_cidr" {
  description = ""
  type        = string
}

variable "sg_ecs_ingress" {
  description = ""
  type        = list(string)
  default     = []
}

variable "sg_ecs_egress" {
  description = ""
  type        = list(string)
  default     = []
}

variable "ecs_sg_tags" {
  description = ""
  type        = map(string)
  default     = {}
}

variable "sg_alb_ingress" {
  description = ""
  type        = list(string)
  default     = []
}

variable "sg_alb_egress" {
  description = ""
  type        = list(string)
  default     = []
}

variable "alb_sg_tags" {
  description = ""
  type        = map(string)
  default     = {}
}

variable "rds_sg_tags" {
  description = ""
  type        = map(string)
  default     = {}
}

// ECS

variable "container_name" {
  description = ""
  type        = string
}

variable "container_image" {
  description = ""
  type        = string
}

variable "container_memory" {
  description = ""
  type        = string
}

variable "container_cpu" {
  description = ""
  type        = string
}

variable "database_name" {
  description = ""
  type        = string
}

variable "database_password_secretsmanager_secret_arn" {
  description = ""
  type        = string
}

variable "database_username_secretsmanager_secret_arn" {
  description = ""
  type        = string
}

// ALB

variable "private_certificate_arn" {
  description = ""
  type        = string
}

// RDS 

variable "rds_cluster_parameter_group_family" {
  description = "The family of the DB parameter group."
  type        = string
  default     = ""
}

variable "rds_cluster_parameter" {
  description = "A list of DB parameters to apply. Note that parameters may differ from a family to an other. Full list of all parameters can be discovered via aws rds describe-db-parameters after initial creation of the group."
  type        = any
  default     = []
}

variable "rds_cluster_parameter_group_tags" {
  description = "A map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  type        = map(any)
  default     = {}
}

variable "rds_db_parameter_group_family" {
  description = "The family of the DB parameter group."
  type        = string
  default     = ""
}

variable "rds_db_parameter" {
  description = "A list of DB parameters to apply. Note that parameters may differ from a family to an other. Full list of all parameters can be discovered via aws rds describe-db-parameters after initial creation of the group."
  type        = any
  default     = []
}

variable "rds_db_parameter_group_tags" {
  description = "A map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  type        = map(any)
  default     = {}
}

variable "rds_db_subnet_group_tags" {
  description = "tags for the db subnet groups"
  type        = map(any)
  default     = {}
}

// Aurora Cluster

variable "rds_source_region" {
  description = " The source region for an encrypted replica DB cluster."
  type        = string
  default     = null
}

variable "rds_engine" {
  description = "The name of the database engine to be used for this DB cluster. Defaults to aurora. Valid Values: "
  type        = string
  default     = null
}

variable "rds_engine_version" {
  description = "The database engine version. Updating this argument results in an outage."
  type        = string
  default     = ""
}

variable "rds_allow_major_version_upgrade" {
  description = " Enable to allow major engine version upgrades when changing engine versions."
  type        = bool
  default     = false
}

variable "rds_apply_immediately" {
  description = ""
  type        = bool
  default     = false
}

variable "rds_kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying kms_key_id, storage_encrypted needs to be set to true."
  type        = string
  default     = null
}

variable "rds_database_name" {
  description = "Name for an automatically created database on cluster creation. "
  type        = string
  default     = null
}

variable "rds_username" {
  description = "Username for the master DB user. Please refer to the RDS Naming Constraints. This argument does not support in-place updates and cannot be changed during a restore from snapshot."
  type        = string
  default     = null
}

variable "rds_master_password" {
  description = " Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. "
  type        = string
  default     = null
}

variable "rds_port" {
  description = "The database port"
  type        = number
  default     = null
}

variable "rds_backtrack_window" {
  description = "The target backtrack window, in seconds. Only available for aurora engine currently. To disable backtracking, set this value to 0. "
  type        = number
  default     = 0
}

variable "rds_enabled_cloudwatch_logs_exports" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: \"09:46-10:16\". Must not overlap with maintenance_window."
  type        = list(string)
  default     = []
}

variable "rds_cluster_tags" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  type        = any
  default     = {}
}

// RDS instance

variable "rds_multi_az_enabled" {
  description = "if want to enable multiAz for rds cluster then set true to this"
  type        = bool
  default     = false
}

variable "rds_instance_engine" {
  description = "The name of the database engine to be used for the RDS instance. Defaults to aurora. "
  type        = string
  default     = "aurora"
}

variable "rds_instance_engine_version" {
  description = "he database engine version. When managing the engine version in the cluster,"
  type        = string
  default     = null
}

variable "rds_instance_class" {
  description = "The instance class to use. For details on CPU and memory, see Scaling Aurora DB Instances. Aurora uses db.* instance classes/types. "
  type        = string
  default     = null
}

variable "rds_instance_apply_immediately" {
  description = "pecifies whether any database modifications are applied immediately, or during the next maintenance window. Default isfalse."
  type        = bool
  default     = false
}

variable "rds_instance_tags" {
  description = " A map of tags to assign to the instance."
  type        = any
  default     = {}
}

// Route53

variable "domain_name" {
  description = ""
  type        = string
}

variable "route53_record_name" {
  description = ""
  type        = string
}

// ses 

variable "email" {
  description = ""
  type        = list(string)
  default     = []
}

// EC2 

variable "instance_ami" {
  description = ""
  type        = string
}

variable "key_name" {
  description = ""
  type        = string
}

# variable "" {
#   description = ""
#   type =
#   default =
# }

# variable "" {
#   description = ""
#   type =
#   default =
# }

# variable "" {
#   description = ""
#   type =
#   default =
# }