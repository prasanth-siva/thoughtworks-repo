aws_region     = "us-east-2"
vpc_cidr_block = "172.69.0.0/16"
private_subnets     = ["172.69.5.0/24", "172.69.6.0/24", "172.69.8.0/24", "172.69.4.0/24"]
private_subnet_name = ["mediawiki-app-az1", "mediawiki-app-az2", "mediawiki-mysql", "mediawiki-operation"]
public_subnets      = ["172.69.101.0/24", "172.69.102.0/24", "172.69.103.0/24", "172.69.104.0/24"]
public_subnet_name  = ["mediawiki-squid-az1", "mediawiki-squid-az2", "mediawiki-alb1", "mediawiki-alb2"]

prod_setup = {
  app          = "t2.micro"
  mysql        = "t2.micro"
}

staging_setup = {
  app          = "t2.micro"
  mysql        = "t2.micro"
}

ami_names = {
  mediawiki = "CentOS-Linux-7-HVM"
}

app_min_count        = 2
app_max_count        = 4
app_desired_count    = 2
protect_scalein  = true

usecase              = "mediawiki-prod"
product              = "mediawiki"
environment          = "prod"
key_pair             = "Mediawiki"
compliance           = "nonpci"
zone_name            = "mw.net"
