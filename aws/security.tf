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

resource "tls_private_key" "priv_key" {
    algorithm = "RSA"
    rsa_bits  = 4096
  }

  resource "aws_key_pair" "generated_key" {
    key_name   = var.key_name
    public_key = tls_private_key.priv_key.public_key_openssh
  }