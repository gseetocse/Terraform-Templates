provider "aws" {
  region     = "${var.region}"
}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_CIDR}"
  tags = {
    "Name" = "${var.vpc_name}"
  }
}

/*
  Create Subnets
 */
 resource "aws_subnet" "Management-Subnet" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.management_CIDR}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    "Name" = "${var.vpc_name} Management Subnet"
  }
}
resource "aws_subnet" "Outside-Subnet" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.public_CIDR}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    "Name" = "${var.vpc_name} Outside Subnet"
  }
}
resource "aws_subnet" "Inside-Subnet" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.private_CIDR}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    "Name" = "${var.vpc_name} Inside Subnet"
  }
}

/*
  Create "Allow All" Security Group
 */
resource "aws_security_group" "SG-Allow-All" {
  name        = "SG-Allow-All"
  description = "Security Group to allow all traffic"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "SG-Allow-All"
  }
}

/*
  Create Network Interfaces
 */
resource "aws_network_interface" "FMCv-Management" {
  subnet_id       = "${aws_subnet.Management-Subnet.id}"
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  private_ips_count = 0
  private_ips = ["${var.fmc_IP}"]
  tags = {
    "Name" = "FMCv-Management"
  }
}
resource "aws_network_interface" "FTDv-Management" {
  subnet_id       = "${aws_subnet.Management-Subnet.id}"
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  private_ips_count = 0
  private_ips = ["${var.management_IP}"]
  tags = {
    "Name" = "FTDv-Management"
  }
}
resource "aws_network_interface" "FTDv-Diagnostic" {
  subnet_id       = "${aws_subnet.Management-Subnet.id}"
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  private_ips_count = 0
  private_ips = ["${var.diagnostic_IP}"]
  tags = {
    "Name" = "FTDv-Diagnostic"
  }
}
resource "aws_network_interface" "FTDv-Outside" {
  subnet_id       = "${aws_subnet.Outside-Subnet.id}"
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  private_ips_count = 0
  private_ips = ["${var.public_IP}"]
  tags = {
    "Name" = "FTDv-Outside"
  }
}
resource "aws_network_interface" "FTDv-Inside" {
  subnet_id       = "${aws_subnet.Inside-Subnet.id}"
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  private_ips_count = 0
  private_ips = ["${var.private_IP}"]
  tags = {
    "Name" = "FTDv-Inside"
  }
}

/*
  Create Internet Gateway
 */
resource "aws_internet_gateway" "Internet-Gateway" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    "Name" = "${var.vpc_name} Internet Gateway"
  }
}

/*
  Create Outside Route Table
 */
resource "aws_route_table" "Route-Table-Outside" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    "Name" = "${var.vpc_name} Outside Route Table"
  }
}
resource "aws_route" "Default-Route" {
  route_table_id          = "${aws_route_table.Route-Table-Outside.id}"
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.Internet-Gateway.id}"
}
resource "aws_route_table_association" "Route-Table-Association-Management" {
  subnet_id      = "${aws_subnet.Management-Subnet.id}"
  route_table_id = "${aws_route_table.Route-Table-Outside.id}"
}
resource "aws_route_table_association" "Route-Table-Association-Outside" {
  subnet_id      = "${aws_subnet.Outside-Subnet.id}"
  route_table_id = "${aws_route_table.Route-Table-Outside.id}"
}

/*
  Create Inside Route Table
 */
resource "aws_route_table" "Route-Table-Inside" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    "Name" = "${var.vpc_name} Inside Route Table"
  }
}
resource "aws_route_table_association" "Route-Table-Association-Inside" {
  subnet_id      = "${aws_subnet.Inside-Subnet.id}"
  route_table_id = "${aws_route_table.Route-Table-Inside.id}"
}

/*
  Create EIP
 */
resource "aws_eip" "FMC-EIP" {
  vpc   = true
  depends_on = ["aws_vpc.main", "aws_internet_gateway.Internet-Gateway"]
  tags = {
    "Name" = "FMCv Management IP"
  }
}
resource "aws_eip" "Management-EIP" {
  vpc   = true
  depends_on = ["aws_vpc.main", "aws_internet_gateway.Internet-Gateway"]
  tags = {
    "Name" = "FTDv Management IP"
  }
}
resource "aws_eip" "Outside-EIP" {
  vpc   = true
  depends_on = ["aws_vpc.main", "aws_internet_gateway.Internet-Gateway"]
  tags = {
    "Name" = "FTDv Outside IP"
  }
}

resource "aws_eip_association" "FMC-EIP-Association" {
  network_interface_id = "${aws_network_interface.FMCv-Management.id}"
  allocation_id        = "${aws_eip.FMC-EIP.id}"
}
resource "aws_eip_association" "Management-EIP-Association" {
  network_interface_id = "${aws_network_interface.FTDv-Management.id}"
  allocation_id        = "${aws_eip.Management-EIP.id}"
}
resource "aws_eip_association" "Outside-EIP-Association" {
  network_interface_id = "${aws_network_interface.FTDv-Outside.id}"
  allocation_id        = "${aws_eip.Outside-EIP.id}"
}

/*
  Fiters to get the most recent BYOL FMCv image
 */
data "aws_ami" "cisco-fmc-lookup" {
  most_recent = true

  filter {
    name = "name"
    values = ["FMCv*"]
  }

  filter {
    name = "product-code"
    values = ["bhx85r4r91ls2uwl69ajm9v1b"]
  }

  owners = ["679593333241"]
}

/*
  Set up the FMC configuration file
 */
data "template_file" "FMCv-init" {
  template = "${file("fmc_config.txt")}"

  vars {
    fmc_password = "${var.fmc_password}"
    fmc_hostname = "${var.fmc_hostname}"
  }
}

/*
  Create FMCv Instance
 */
resource "aws_instance" "FMCv" {
  ami           = "${data.aws_ami.cisco-fmc-lookup.id}"
  instance_type = "${var.fmc_instance_size}"
  tags          = {
    Name = "Cisco FMCv"
  }

  user_data = "${data.template_file.FMCv-init.rendered}"

  network_interface {
    device_index = 0
    network_interface_id = "${aws_network_interface.FMCv-Management.id}"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.FMCv.public_ip} > fmc_ip_address.txt"
  }
}

/*
  Fiters to get the most recent BYOL FTDv image
 */
data "aws_ami" "cisco-ftd-lookup" {
  most_recent = true

  filter {
    name = "name"
    values = ["FTDv*"]
  }

  filter {
    name = "product-code"
    values = ["a8sxy6easi2zumgtyr564z6y7"]
  }

  owners = ["679593333241"]
}

/*
  Set up the FTD configuration file
 */
data "template_file" "FTDv-init" {
  template = "${file("ftd_config.txt")}"

  vars {
    ftd_password = "${var.ftd_password}"
    ftd_hostname = "${var.ftd_hostname}"
    fmc_ip       = "${var.fmc_IP}",
    fmc_reg_key  = "${var.fmc_reg_key}",
    fmc_nat_id   = "${var.fmc_nat_id}"
  }
}

/*
  Create FTDv Instance
 */
resource "aws_instance" "FTDv" {
  ami           = "${data.aws_ami.cisco-ftd-lookup.id}"
  instance_type = "${var.ftd_instance_size}"
  tags          = {
    Name = "Cisco FTDv"
  }

  user_data = "${data.template_file.FTDv-init.rendered}"

  network_interface {
    device_index = 0
    network_interface_id = "${aws_network_interface.FTDv-Management.id}"
  }

  network_interface {
    device_index = 1
    network_interface_id = "${aws_network_interface.FTDv-Diagnostic.id}"
  }

  network_interface {
    device_index = 2
    network_interface_id = "${aws_network_interface.FTDv-Outside.id}"
  }

  network_interface {
    device_index = 3
    network_interface_id = "${aws_network_interface.FTDv-Inside.id}"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.FTDv.public_ip} > ftd_ip_address.txt"
  }
}

output "FMCv-IP" {
  value = "${aws_eip.FMC-EIP.public_ip}"
}
output "FTDv-IP" {
  value = "${aws_eip.Management-EIP.public_ip}"
}