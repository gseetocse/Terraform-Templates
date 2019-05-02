// Firepower Management Configuration
fmc_password = "cisco123"
fmc_hostname = "fmc"
ftd_password = "cisco123"
ftd_hostname = "firepower"
fmc_IP       = "10.0.3.20"
fmc_reg_key  = "cisco123"
fmc_nat_id   = ""

// Subnet / Firewall IP Configuration
diagnostic_IP   = "10.0.3.11"
management_CIDR = "10.0.3.0/24"
management_IP   = "10.0.3.10"
private_CIDR    = "10.0.1.0/24"
private_IP      = "10.0.1.10"
public_CIDR     = "10.0.0.0/24"
public_IP       = "10.0.0.10"

// AWS Region
region = "us-east-1"

// VPC Configuration
vpc_name = "FTDv + FMCv Single-Tier App"
vpc_CIDR = "10.0.0.0/22"
