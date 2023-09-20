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

      // Create RDS Subnet group
  resource "aws_db_subnet_group" "db_subnet_group" {
    name       = "wordpress-db-subnet-group"
    subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  }
