# Wordpress with Terraform

## Description
This is a terraforming project with the aim of creating a functioning MySQL database and one ec2 instance with a wordpress installed on it (as well as the necessary resources to support it) with the usage of AWS (and eventually Azure).

## Created resources
- VPC
- Several subnets (2 private and 1 public)
- Internet gateway
- Route table (and associations)
- Security group
- EC2 instance (ubuntu based)
- Subnet group
- Security groups (2)
- Key pair
- MySQL database 

## Used Technologies

- Terraform
- AWS
- Azure (work-in-progress)
- MySQL

## Installation

This project requires that your machine has terraform installed and that you have a working AWS (and Azure CLI) on it.

1. Download this repository to your machine
2. Navigate to the project directory
3. Choose between aws and azure and go into the chosen folder
4. Init the backend for terraform
  ```sh
  terraform init
  ```
4. Take a look at AWS resourcces you are about to create
  ```sh
  terraform plan
  ```
5. Create the resources
  ```sh
  terraform apply -auto-approve
  ```
Once all the resaources are created you can check it out on the ip address you can see in the terminal.

## Addendum

- You can configure the properties of the database and the vpc infrastructure with the `variables.tf` file.
- After the terraform file finished you might need to wait a bit for the ec2 instance to finish fully setting up.

### TODO
-The azure version of this project is still under construction, and not as of yet functions.
