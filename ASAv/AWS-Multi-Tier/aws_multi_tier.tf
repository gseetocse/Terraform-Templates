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
resource "aws_subnet" "Tier-1-Subnet" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.tier_1_CIDR}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    "Name" = "${var.vpc_name} Tier 1 Subnet"
  }
}
resource "aws_subnet" "Tier-2-Subnet" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.tier_2_CIDR}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    "Name" = "${var.vpc_name} Tier 2 Subnet"
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
resource "aws_network_interface" "ASAv-Management" {
  subnet_id       = "${aws_subnet.Management-Subnet.id}"
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  private_ips_count = 0
  private_ips = ["${var.management_IP}"]
  tags = {
    "Name" = "ASAv-Management"
  }
}
resource "aws_network_interface" "ASAv-Outside" {
  subnet_id       = "${aws_subnet.Outside-Subnet.id}"
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  private_ips_count = 0
  private_ips = ["${var.public_IP}"]
  tags = {
    "Name" = "ASAv-Outside"
  }
}
resource "aws_network_interface" "ASAv-Tier-1" {
  subnet_id       = "${aws_subnet.Tier-1-Subnet.id}"
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  private_ips_count = 0
  private_ips = ["${var.tier_1_IP}"]
  tags = {
    "Name" = "ASAv-Tier-1"
  }
}
resource "aws_network_interface" "ASAv-Tier-2" {
  subnet_id       = "${aws_subnet.Tier-2-Subnet.id}"
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  private_ips_count = 0
  private_ips = ["${var.tier_2_IP}"]
  tags = {
    "Name" = "ASAv-Tier-2"
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
resource "aws_route_table_association" "Route-Table-Association-Tier-1" {
  subnet_id      = "${aws_subnet.Tier-1-Subnet.id}"
  route_table_id = "${aws_route_table.Route-Table-Inside.id}"
}
resource "aws_route_table_association" "Route-Table-Association-Tier-2" {
  subnet_id      = "${aws_subnet.Tier-2-Subnet.id}"
  route_table_id = "${aws_route_table.Route-Table-Inside.id}"
}

/*
  Create EIP
 */
 resource "aws_eip" "Management-EIP" {
  vpc   = true
  depends_on = ["aws_vpc.main", "aws_internet_gateway.Internet-Gateway"]
  tags = {
    "Name" = "ASAv Management IP"
  }
}
resource "aws_eip" "Outside-EIP" {
  vpc   = true
  depends_on = ["aws_vpc.main", "aws_internet_gateway.Internet-Gateway"]
  tags = {
    "Name" = "ASAv Outside IP"
  }
}
resource "aws_eip_association" "Management-EIP-Association" {
  network_interface_id = "${aws_network_interface.ASAv-Management.id}"
  allocation_id        = "${aws_eip.Management-EIP.id}"
}
resource "aws_eip_association" "Outside-EIP-Association" {
  network_interface_id = "${aws_network_interface.ASAv-Outside.id}"
  allocation_id        = "${aws_eip.Outside-EIP.id}"
}

/*
  Fiters to get the most recent BYOL ASAv image
 */
data "aws_ami" "cisco-asa-lookup" {
  most_recent = true

  filter {
    name = "name"
    values = ["ASAv*"]
  }

  filter {
    name = "product-code"
    values = ["663uv4erlxz65quhgaz9cida0"]
  }

  owners = ["679593333241"]
}

/*
  Create ASAv Instance
 */
resource "aws_instance" "ASAv" {
  ami           = "${data.aws_ami.cisco-asa-lookup.id}"
  instance_type = "${var.instance_size}"
  key_name      = "${var.key_pair}"
  tags          = {
    Name = "Cisco ASA (Remote Access)"
  }

  network_interface {
    device_index = 0
    network_interface_id = "${aws_network_interface.ASAv-Management.id}"
  }

  network_interface {
    device_index = 1
    network_interface_id = "${aws_network_interface.ASAv-Outside.id}"
  }

  network_interface {
    device_index = 2
    network_interface_id = "${aws_network_interface.ASAv-Tier-1.id}"
  }

  network_interface {
    device_index = 3
    network_interface_id = "${aws_network_interface.ASAv-Tier-2.id}"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.ASAv.public_ip} > ip_address.txt"
  }
}

output "asa-management-ip" {
  value = "${aws_eip.Management-EIP.public_ip}"
}