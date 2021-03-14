output "mysql_database_host" {
  description = "The database host."
  value       = aws_db_instance.mysql_database.address
}

output "mysql_database_name" {
  description = "The database name."
  value       = aws_db_instance.mysql_database.name
}

output "mysql_database_port" {
  description = "The database port."
  value       = var.database_port
}

output "rds_mysql_sg_id" {
  value = aws_security_group.mysql_database_security_group.id
}

output "liferay_endpoint" {
  value = aws_db_instance.mysql_database.endpoint
}


output "lfrdb_arn" {
  value = aws_db_instance.mysql_database.arn
}