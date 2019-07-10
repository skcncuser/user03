provider "aws" {
	region = "ap-northeast-1"
}

resource "aws_vpc" "user03-final" {
	cidr_block = "103.0.0.0/16"
	enable_dns_hostnames = true
	enable_dns_support = true
	instance_tenancy = "default"
	tags = {
		Name = "user03-final"
	}
}

resource "aws_subnet" "subnet1" {
	vpc_id = "${aws_vpc.user03-final.id}"
	availability_zone = "ap-northeast-1a"
	cidr_block = "103.0.1.0/24"
	tags = {
		Name = "user03-final-subnet1"
	}
}

resource "aws_subnet" "subnet2" {
	vpc_id = "${aws_vpc.user03-final.id}"
	availability_zone = "ap-northeast-1c"
	cidr_block = "103.0.2.0/24"
	tags = {
		Name = "user03-final-subnet2"
	}
}

resource "aws_subnet" "subnet3" {
	vpc_id = "${aws_vpc.user03-final.id}"
	availability_zone = "ap-northeast-1a"
	cidr_block = "103.0.3.0/24"
	tags = {
		Name = "user03-final-subnet3"
	}
}

resource "aws_internet_gateway" "user03-final" {
vpc_id = "${aws_vpc.user03-final.id}"
	tags = {
		Name = "user03-final"
	}
}

resource "aws_eip" "nat_user03-final_1" {
	vpc = true
}

resource "aws_nat_gateway" "user03-final" {
  allocation_id = "${aws_eip.nat_user03-final_1.id}"
  subnet_id     = "${aws_subnet.subnet3.id}"
}


resource "aws_default_security_group" "user03-final_default" {
	vpc_id = "${aws_vpc.user03-final.id}"
	ingress {
		protocol = -1
		self = true
		from_port = 0
		to_port = 0
	}
	
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags = {
		Name = "user03-final-default"
	}
}

# dev_public
resource "aws_route_table" "user03-final_public" {
  vpc_id = "${aws_vpc.user03-final.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.user03-final.id}"
  }

  tags = {
    Name = "user03-final-public"
  }
}

resource "aws_route_table_association" "user03-final_subnet3" {
  subnet_id      = "${aws_subnet.subnet3.id}"
  route_table_id = "${aws_route_table.user03-final_public.id}"
}

# dev_private_1
resource "aws_route_table" "user03-final_subnet1" {
  vpc_id = "${aws_vpc.user03-final.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.user03-final.id}"
  }

  tags = {
    Name = "user03-final-subnet1"
  }
}

resource "aws_route_table_association" "user03-final_subnet1" {
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.user03-final_subnet1.id}"
}

# dev_private_2
resource "aws_route_table" "user03-final_subnet2" {
  vpc_id = "${aws_vpc.user03-final.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.user03-final.id}"
  }

  tags = {
    Name = "user03-final-subnet2"
  }
}

resource "aws_route_table_association" "user03-final_subnet2" {
  subnet_id      = "${aws_subnet.subnet2.id}"
  route_table_id = "${aws_route_table.user03-final_subnet2.id}"
}

resource "aws_default_network_acl" "user03-final_default" {
  default_network_acl_id = "${aws_vpc.user03-final.default_network_acl_id}"

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  subnet_ids = [
    "${aws_subnet.subnet1.id}",
    "${aws_subnet.subnet2.id}",
  ]

  tags = {
    Name = "user03-final-default"
  }
}

resource "aws_security_group" "vm1" {
  name        = "vm1"
  description = "open ssh port for vm1"

  vpc_id = "${aws_vpc.user03-final.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vm1"
  }
}

resource "aws_eip" "vm1" {
  instance = "${aws_instance.vm1.id}"
  vpc      = true
}

resource "aws_instance" "vm1" {
  ami               = "ami-4af5022c"
  availability_zone = "ap-northeast-1a"
  instance_type     = "t2.nano"
  key_name          = "user03-final-kp"

  vpc_security_group_ids = [
    "${aws_security_group.vm1.id}",
    "${aws_default_security_group.user03-final_default.id}",
  ]

  subnet_id                   = "${aws_subnet.subnet1.id}"
  associate_public_ip_address = true

  tags = {
    Name = "vm1"
  }
}

resource "aws_security_group" "vm2" {
  name        = "vm2"
  description = "open ssh port for vm2"

  vpc_id = "${aws_vpc.user03-final.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vm2"
  }
}

resource "aws_eip" "vm2" {
  instance = "${aws_instance.vm2.id}"
  vpc      = true
}

resource "aws_instance" "vm2" {
  ami               = "ami-4af5022c"
  availability_zone = "ap-northeast-1c"
  instance_type     = "t2.nano"
  key_name          =  "user03-final-kp"
  
  vpc_security_group_ids = [
    "${aws_security_group.vm2.id}",
    "${aws_default_security_group.user03-final_default.id}",
  ]

  subnet_id                   = "${aws_subnet.subnet2.id}"
  associate_public_ip_address = true

  tags = {
    Name = "vm2"
  }
}

