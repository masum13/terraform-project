environment = "local"
project = "credencys"
tfstate_bucket = "test-terraform"
region = "us-east-1"

vpc_cidr_block = "10.0.0.0/22"
availability_zones = ["us-east-1a","us-east-1b","us-east-1c"]

public_subnet_1_cidr = "10.0.0.0/25"
public_subnet_2_cidr = "10.0.0.128/25"
public_subnet_3_cidr = "10.0.1.0/25"

private_subnet_1_cidr = "10.0.1.128/25"
private_subnet_2_cidr = "10.0.2.0/25"
private_subnet_3_cidr = "10.0.2.128/25"

// Alb-sg

sg_alb_ingress = [{
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
},
{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}]

sg_alb_egress = [{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}]

// ECS

container_name = "test"
container_image = "nginx:latest"
container_memory = "1024"
container_cpu = "512"

database_name = "test-db"

// ALB
# private_certificate_arn = ""

//  RDS aurora cluster

rds_cluster_parameter_group_family = "aurora-mysql5.7"
rds_db_parameter_group_family = "aurora-mysql5.7"

rds_source_region = "us-east-1"
rds_engine = "aurora-mysql"
rds_engine_version = "5.7.mysql_aurora.2.10.2"

// DatabaseName must begin with a letter and contain only alphanumeric characters.
rds_database_name = "testDB"
rds_username = "test"

rds_port = 3306

// RDS aurora instance

rds_multi_az_enabled = false
rds_instance_class = "db.t2.small"

// Route53

domain_name = "myapplication.tech"
route53_record_name = "alb.myapplication.tech"

// SES

email = ["parth.shukla@compufytechnolab.com"]

// Bastion host

instance_ami = "ami-0cff7528ff583bf9a"
key_name = "bastion-host"

// Cloudfront

cloudfront_default_certificate = true
cloud_front_min_ttl = 0
cloud_front_default_ttl = 3600 