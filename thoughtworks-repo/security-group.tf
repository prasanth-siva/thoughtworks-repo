resource "aws_security_group" "media-wiki-app" {
  name        = "media-wiki-app"
  description = "Security group for media-wiki-app"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "media-wiki-app"
    environment = var.environment
    product     = var.product
  }
}

resource "aws_security_group" "media-wiki-alb" {
  name        = "media-wiki-alb"
  description = "Security group for media-wiki-alb"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "media-wiki-alb"
    environment = var.environment
    product     = var.product
  }
}

resource "aws_security_group" "media-wiki-mysql" {
  name        = "media-wiki-mysql"
  description = "Security group for media-wiki-mysql"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "media-wiki-mysql"
    environment = var.environment
    product     = var.product
  }
}

resource "aws_security_group" "media-common-sg" {
  name        = "media-common-sg"
  description = "Security group for media-common-sg"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "media-common-sg"
    environment = var.environment
    product     = var.product
  }
}

resource "aws_security_group" "mediaw-jup-sg" {
  name        = "mediaw-jup-sg"
  description = "Security group for mediaw-jup-sg"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "mediaw-jup-sg"
    environment = var.environment
    product     = var.product
  }
}

resource "aws_security_group_rule" "common_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.LFR_jump_sg.id
  security_group_id        = aws_security_group.media-common-sg.id
  description              = "allow_ssh_from_jump"
}

resource "aws_security_group_rule" "common_to_jump" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.LFR_jump_sg.id
  source_security_group_id = aws_security_group.media-common-sg.id
  description              = "allow_ssh_from_jump"
}

resource "aws_security_group_rule" "outb_app_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.media-wiki-app.id
}

resource "aws_security_group_rule" "outb_app_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.media-wiki-app.id
}

resource "aws_security_group_rule" "outb_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.media-wiki-mysql.id
}

resource "aws_security_group_rule" "outb_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.media-wiki-mysql.id
}

