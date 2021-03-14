resource "aws_security_group" "mysql_database_security_group" {
  name        = "database-security-group-${var.component}-${var.deployment_identifier}"
  description = "Allow access to ${var.component} MySQL database from private network."
  vpc_id      = var.vpc_id

  tags = {
    Name                 = "sg-database-${var.component}-${var.deployment_identifier}"
    Component            = var.component
    DeploymentIdentifier = var.deployment_identifier
  }

}

resource "aws_security_group_rule" "mysql_database_security_group_rule" {
  type              = "ingress"
  from_port         = var.database_port
  to_port           = var.database_port
  protocol          = "tcp"
  cidr_blocks       = [var.private_network_cidr]
  description       = "mysql access rule"
  security_group_id = aws_security_group.mysql_database_security_group.id
}