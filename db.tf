resource "aws_rds_cluster_parameter_group" "this" {
  name   = "${local.name_prefix}-cluster-parameter-group"
  family = var.rds_cluster_parameter_group_family

  dynamic "parameter" {
    for_each = var.rds_cluster_parameter
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }
  tags = merge({ Name = "${local.name_prefix}-cluster-parameter-group" }, var.rds_cluster_parameter_group_tags)
}

resource "aws_db_parameter_group" "this" {
  name   = "${local.name_prefix}-instance-parameter-group"
  family = var.rds_db_parameter_group_family

  dynamic "parameter" {
    for_each = var.rds_db_parameter
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }
  tags = merge({ Name = "${local.name_prefix}-instance-parameter-group" }, var.rds_db_parameter_group_tags)
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]

  tags = merge({ Name = "${local.name_prefix}-db-subnet-group" }, var.rds_db_subnet_group_tags)
}

resource "aws_rds_cluster" "this" {

  availability_zones = var.availability_zones

  cluster_identifier              = "${local.name_prefix}-db-cluster"
  source_region                   = var.rds_source_region
  engine                          = var.rds_engine
  engine_mode                     = "provisioned"
  engine_version                  = var.rds_engine_version
  allow_major_version_upgrade     = var.rds_allow_major_version_upgrade
  kms_key_id                      = var.rds_kms_key_id
  database_name                   = var.rds_database_name
  master_username                 = var.rds_username
  master_password                 = var.rds_master_password
  deletion_protection             = true
  backup_retention_period         = 3
  port                            = var.rds_port
  db_subnet_group_name            = aws_db_subnet_group.this.id
  vpc_security_group_ids          = [aws_security_group.rds_sg.id]
  storage_encrypted               = true
  apply_immediately               = var.rds_apply_immediately
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name
  backtrack_window                = var.rds_backtrack_window
  copy_tags_to_snapshot           = true

  tags = merge({ Name = "${local.name_prefix}-db-cluster" }, var.rds_cluster_tags)

  lifecycle {
    ignore_changes = [cluster_members]
  }
}

resource "aws_rds_cluster_instance" "this" {

  identifier                   = "${local.name_prefix}-db-instance-1"
  cluster_identifier           = aws_rds_cluster.this.id
  engine                       = var.rds_engine
  engine_version               = var.rds_engine_version
  instance_class               = var.rds_instance_class
  publicly_accessible          = false
  db_subnet_group_name         = aws_db_subnet_group.this.id
  db_parameter_group_name      = aws_db_parameter_group.this.name
  apply_immediately            = var.rds_apply_immediately
  auto_minor_version_upgrade   = false
  promotion_tier               = 0
  performance_insights_enabled = true

  # Updating engine version forces replacement of instances, and they shouldn't be replaced
  # because cluster will update them if engine version is changed
  lifecycle {
    ignore_changes = [
      engine_version
    ]
  }
  tags = merge({ Name = "${local.name_prefix}-db-instance-1" }, var.rds_instance_tags)

}

resource "aws_rds_cluster_instance" "multiAZ" {
  count = var.rds_multi_az_enabled ? 1 : 0

  identifier                   = "${local.name_prefix}-db-instance-2"
  cluster_identifier           = aws_rds_cluster.this.id
  engine                       = var.rds_engine
  engine_version               = var.rds_engine_version
  instance_class               = var.rds_instance_class
  publicly_accessible          = false
  db_subnet_group_name         = aws_db_subnet_group.this.id
  db_parameter_group_name      = aws_db_parameter_group.this.name
  apply_immediately            = var.rds_apply_immediately
  auto_minor_version_upgrade   = false
  promotion_tier               = 1
  performance_insights_enabled = true

  # Updating engine version forces replacement of instances, and they shouldn't be replaced
  # because cluster will update them if engine version is changed
  lifecycle {
    ignore_changes = [
      engine_version
    ]
  }
  tags = merge({ Name = "${local.name_prefix}-db-instance-2" }, var.rds_instance_tags)

}