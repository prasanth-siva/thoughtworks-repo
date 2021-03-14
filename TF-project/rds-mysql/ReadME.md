Terraform AWS RDS MySQL
==========================
A Terraform module for deploying an RDS MySQL instance in AWS.

The AWS RDS requires:
* An existing VPC 
 
The RDS consists of:
* security groups
* subnet groups

Usage
-----

To use the module, include something like the following in your terraform
configuration:

```hcl-terraform
module "database" {
  source = "infrablocks/rds-mysql/aws"
  version = "0.1.0"

  region = "eu-west-2"
  vpc_id = "vpc-b197da6b"
  private_subnet_ids = "subnet-7cd8832a,subnet-0199db7c"
  private_network_cidr = "10.0.0.0/16"

  component = "identity-server"
  deployment_identifier = "2f3eddcb"

  database_instance_class = "db.t2.medium"
  database_version = "5.7"

  database_name = "identity"
  database_master_user = "admin"
  database_master_password = "1D$£#J!LKeE£(9d9"
}
```

### Inputs

| Name                            | Description                                                               | Default               | Required |
|---------------------------------|---------------------------------------------------------------------------|:---------------------:|:--------:|
| region                          | The region into which to deploy the database                              | -                     | yes      |
| vpc_id                          | The ID of the VPC into which to deploy the database                       | -                     | yes      |
| component                       | The component this database will serve                                    | -                     | yes      |
| deployment_identifier           | An identifier for this instantiation                                      | -                     | yes      |
| private_network_cidr            | The CIDR of the private network allowed access to the ELB                 | -                     | yes      |
| private_subnet_ids              | The IDs of the private subnets to deploy the database into                | -                     | yes      |
| database_instance_class         | The instance type of the RDS instance.                                    | -                     | yes      |
| database_version                | The database version. If omitted, it lets Amazon decide.                  | -                     | no       |
| database_name                   | The DB name to create. If omitted, no database is created initially.      | -                     | yes      |
| database_master_user_password   | The password for the master database user.                                | -                     | yes      |
| database_master_user            | The username for the master database user.                                | -                     | yes      |
| use_multiple_availability_zones | Whether to create a multi-availability zone database ("yes" or "no").     | "no"                  | yes      |
| use_encrypted_storage           | Whether or not to use encrypted storage for the database ("yes" or "no"). | "no"                  | yes      |
| snapshot_identifier             | The identifier of the snapshot to use to create the database.             | -                     | no       |
| backup_retention_period         | The number of days to retain database backups.                            | 7                     | yes      |
| backup_window                   | The time window in which backups should take place.                       | "01:00-03:00"         | yes      |
| maintenance_window              | The time window in which maintenance should take place.                   | "mon:03:01-mon:05:00" | yes      |


### Outputs

| Name                   | Description       |
|------------------------|-------------------|
| mysql_database_port | The database port |
| mysql_database_host | The database host |
| mysql_database_name | The database name |
