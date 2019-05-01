data "aws_availability_zones" "available" {}
variable "region" {}
variable "instance_size" {
  default = "c4.large"
}
variable "key_pair" {}
variable "management_CIDR" {}
variable "management_IP" {}
variable "private_CIDR" {}
variable "private_IP" {}
variable "public_CIDR" {}
variable "public_IP" {}
variable "vpc_name" {}
variable "vpc_CIDR" {}