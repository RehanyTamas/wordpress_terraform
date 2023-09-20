  #  RDS instance
  resource "aws_db_instance" "wordpress_db" {
    allocated_storage    = 10
    engine               = "mysql"
    engine_version       = "8.0.32"
    instance_class       = var.instance_class
    db_name              = var.db_name
    username             = var.db_user
    password             = var.db_password
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