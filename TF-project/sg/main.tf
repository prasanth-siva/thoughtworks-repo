resource "aws_security_group" "db_mongo_sg" {
  name        = "db_mongo_sg"
  description = "Security group for db_mongo_sg"
  vpc_id      = module.vpc.vpc_id


  tags = {
    Name        = "mongodb-sg"
    usecase     = var.usecase
    environment = var.environment
    monitoring  = "false"
    product     = var.product
  }
}

resource "aws_security_group_rule" "jump_from_mongo" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jump-sg.id
  security_group_id        = aws_security_group.db_mongo_sg.id
}


