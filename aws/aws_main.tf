 provider "aws" {
    region = var.region
    shared_credentials_files = [ var.shared_credentials_file ]
    profile = "default"
  }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

resource "tls_private_key" "priv_key" {
    algorithm = "RSA"
    rsa_bits  = 4096
  }

  resource "aws_key_pair" "generated_key" {
    key_name   = var.key_name
    public_key = tls_private_key.priv_key.public_key_openssh
  }

 // Create a VPC for the Wordpress application
  resource "aws_vpc" "wordpress_vpc" {
    cidr_block = var.VPC_cidr
    enable_dns_support = "true" // gives you an internal domain name
    enable_dns_hostnames = "true" // gives you an internal host name
    tags = {
      Name = "wordpress-vpc"
    }
  }

  // Public Subnet for EC2 instance
  resource "aws_subnet" "public_subnet" {
    vpc_id            = aws_vpc.wordpress_vpc.id
    cidr_block        = var.subnet_cidr[0]
    availability_zone = var.AZ[0]
    map_public_ip_on_launch = "true" // it makes this a public subnet
    tags = {
      Name = "EC2-public-subnet"
    }
  }

  // Private subnet for RDS instance
  resource "aws_subnet" "private_subnet_1" {
    vpc_id            = aws_vpc.wordpress_vpc.id
    cidr_block        = var.subnet_cidr[1]
    availability_zone = var.AZ[1]
    map_public_ip_on_launch = "false" // it makes private subnet
    tags = {
      Name = "RDS-private-subnet-1"
    }
  }

  // Second Private subnet for RDS instance
  resource "aws_subnet" "private_subnet_2" {
    vpc_id            = aws_vpc.wordpress_vpc.id
    cidr_block        = var.subnet_cidr[2]
    availability_zone = var.AZ[2]
    map_public_ip_on_launch = "false" // it makes private subnet
    tags = {
      Name = "RDS-private-subnet-2"
    }
  }

  // Create an Internet Gateway for the VPC
  resource "aws_internet_gateway" "internet_gtw" {
    vpc_id = aws_vpc.wordpress_vpc.id
    tags = {
      Name = "wordpress-igw"
    }
  }

  // Create a route table for the VPC
  resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.wordpress_vpc.id
  }

  // Define the default route for the route table
  resource "aws_route" "default_route" {
    route_table_id         = aws_route_table.route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.internet_gtw.id
  }

  // Associate the route table with the public subnet
  resource "aws_route_table_association" "rtb_association" {
    route_table_id = aws_route_table.route_table.id
    subnet_id      = aws_subnet.public_subnet.id
  }

  // Security group for EC2
  resource "aws_security_group" "instance_sg" {
    name        = "wordpress-sg"
    description = "Security group for WordPress EC2 instance"

    vpc_id = aws_vpc.wordpress_vpc.id

    ingress {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "MYSQL"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  // Security group for RDS
  resource "aws_security_group" "RDS_allow_rule" {
    vpc_id = aws_vpc.wordpress_vpc.id
    ingress {
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      security_groups = ["${aws_security_group.instance_sg.id}"]
    }
    # Allow all outbound traffic.
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "RDS-allow-ec2-sg"
    }
  }

 
    // Create RDS Subnet group
  resource "aws_db_subnet_group" "db_subnet_group" {
    name       = "wordpress-db-subnet-group"
    subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  }

  // Create RDS instance
  resource "aws_db_instance" "wordpress_db" {
    allocated_storage    = 10
    engine               = "mysql"
    engine_version       = "8.0.32"
    instance_class       = var.instance_class
    db_name              = "db"
    username             = "admin"
    password             = "admin_password"
    skip_final_snapshot  = true
    vpc_security_group_ids = [aws_security_group.RDS_allow_rule.id]
    db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id

    // make sure the rds manual password changes is ignored
    lifecycle {
      ignore_changes = [ password ]
    }

    tags = {
      Name = "wordpress-database"
    }
  }

  data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

 resource "aws_instance" "wordpress_instance" {
    ami                   = data.aws_ami.ubuntu.id
    instance_type         = var.instance_type
    subnet_id             = aws_subnet.public_subnet.id  
    vpc_security_group_ids = [aws_security_group.instance_sg.id]
    user_data = data.template_file.user_data.rendered
    key_name              = var.key_name
    tags = {
      Name = "Wordpress.web"
    }

    root_block_device {
      volume_size = var.root_volume_size // in GB
    }

    // this will stop creating EC2 before RDS is provisioned
    depends_on = [ aws_db_instance.wordpress_db ]
  }

  // Crating elastic IP for EC2
  resource "aws_eip" "eip" {
    instance = aws_instance.wordpress_instance.id
  }

  data "template_file" "user_data" {
    template = file("${path.module}/template/user_data.tpl")
    vars = {
      db_username = "admin"
      db_user_password = "admin_password"
      db_name = "db"
      db_RDS = aws_db_instance.wordpress_db.endpoint
    }
  }

// Output IP and RDS Endpoint information
  output "IP" {
    value = aws_eip.eip.public_ip
  }

  output "RDS-endpoint" {
    value = aws_db_instance.wordpress_db.endpoint
  }

  output "INFO" {
    value = "AWS Resources and Wordpress has been provisioned. Go to http://${aws_eip.eip.public_ip}"
  }