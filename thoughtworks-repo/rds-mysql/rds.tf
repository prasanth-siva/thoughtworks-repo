resource "aws_db_instance" "mysql_database" {
  #identifier           = "db-instance-${var.component}-${var.deployment_identifier}"
  identifier           = var.identifier
  allocated_storage    = var.allocated_storage
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = var.database_version
  instance_class       = var.database_instance_class
  name                 = var.database_name
  username             = var.database_master_user
  password             = var.database_master_user_password
  snapshot_identifier  = var.snapshot_identifier
  publicly_accessible  = false
  multi_az             = var.use_multiple_availability_zones == "yes" ? true : false
  storage_encrypted    = var.use_encrypted_storage == "yes" ? true : false
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.database_subnet_group.name
  auto_minor_version_upgrade  = false
  replicate_source_db = var.replicate_source_db
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  #parameter_group_name = aws_db_parameter_group.default.id
  parameter_group_name = var.parameter_group_name

  vpc_security_group_ids = [
    aws_security_group.mysql_database_security_group.id
  ]

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  tags = var.tags
}