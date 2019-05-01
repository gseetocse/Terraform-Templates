data "aws_availability_zones" "available" {}
variable "region" {}
variable "instance_size" {
  default = "c4.large"
}
variable "key_pair" {}
variable "management_CIDR" {}
variable "management_IP" {}
variable "tier_1_CIDR" {}
variable "tier_1_IP" {}
variable "tier_2_CIDR" {}
variable "tier_2_IP" {}
variable "public_CIDR" {}
variable "public_IP" {}
variable "vpc_name" {}
variable "vpc_CIDR" {}