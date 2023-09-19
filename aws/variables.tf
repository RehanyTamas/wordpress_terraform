variable "shared_credentials_file" {
    description = "Location of the AWS credentials file"
    type        = string
    default = "~/.aws/credentials"
}
variable "region" {
    description = "AWS region"
    type        = string
    default = "us-west-2"
}
variable "AZ" {
    description = "Availability Zones"
    type        = list(string)
    default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}
variable "VPC_cidr" {
    description = "CIDR block for the VPC"
    type        = string
    default = "10.0.0.0/16"
}
variable "subnet_cidr" {
    description = "Subnet CIDRs"
    type        = list(string)
    default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}
variable "instance_type" {
    description = "Type of EC2 instance"
    type        = string
    default = "t2.micro"
}
variable "instance_class" {
    description = "Type of RDS instance"
    type        = string
    default = "db.t2.micro"
}
variable "key_name" {
  description = "Name of the EC2 key"
  type = string
  default = "MYKEYEC2"
}
variable "root_volume_size" {
    description = "Size of the root volume"
    type        = number
    default = 22
}