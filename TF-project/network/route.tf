resource "aws_route53_zone" "main" {
  count = var.create_route53_zone ? 1 : 0 
  name  = var.zone_name
  vpc {
    vpc_id = concat(aws_vpc.this.*.id, [""])[0]
  }

  tags = var.tags
}