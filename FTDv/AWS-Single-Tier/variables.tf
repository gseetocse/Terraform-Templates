data "aws_availability_zones" "available" {}
variable "region" {}
variable "instance_size" {
  default = "c4.xlarge"
}
variable "key_pair" {}
variable "diagnostic_IP" {}
variable "management_CIDR" {}
variable "management_IP" {}
variable "private_CIDR" {}
variable "private_IP" {}
variable "public_CIDR" {}
variable "public_IP" {}
variable "vpc_name" {}
variable "vpc_CIDR" {}
variable "ftd_password" {}
variable "ftd_hostname" {}

variable "fmc_IP" {}
variable "fmc_reg_key" {}
variable "fmc_nat_id" {}