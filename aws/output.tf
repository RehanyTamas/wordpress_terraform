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