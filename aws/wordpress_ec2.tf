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
      db_username = var.db_user
      db_user_password = var.db_password
      db_name = var.db_name
      db_RDS = aws_db_instance.wordpress_db.endpoint
    }
  }