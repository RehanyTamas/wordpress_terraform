variable "location" {
  description = "The location where resources will be created"
  default     = "westus2"
}

variable "application_port" {
  description = "The port that you want to expose to the external load balancer"
  default     = 80
}

variable "admin_username" {
  description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
  default = "rt_wordpress"
}

variable "admin_password" {
  description = "Default password for admin account"
  default = "rt_wordpress_password"
}

variable "database_admin_login" {
  default = "wordpress"
}

variable "database_admin_password" {
  default = "w0rdpr3ss@p4ss"
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)

  default = {
    environment = "Development"
  }
}

/*variable "az_appID" {
  description = "Credential appID for Azure" 
  default = "<insert-appID-here>"
}

variable "az_displayName" {
  description = "Credential displayName for Azure" 
  default = "<insert-displayname-here>"
}

variable "az_password" {
  description = "Credential password for Azure" 
  default = "<insert-password-here>"
}

variable "az_tenant" {
  description = "Credential tenant for Azure" 
  default = "<insert-tenant-here>"
}
*/