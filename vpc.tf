provider "aws"{
  region = "ap-south-1"
  profile= "honipiple"
}

#create vpc

resource "aws_vpc" "main"{
  cidr_block = "192.168.0.0/16"
  enable_dns_hostname = "true"
 
  tags ={
    Name = "honivpc"
  }
}


#subnets for vpc
#subnet 1

resource "aws_subnet" "Pub_subnet"{
  vpc_id  =  "${aws_vpc.main.id}"
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"


 tags = {
   Name = "publicsubnet-1a"
  }
}

#subnet 2

resource "aws_subnet" "pri_subnet" {
  vpc_id  =  "${aws_vpc.main.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"


  tags = {
    Name = "privatesubnet-1b"
  }
}


#internet gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.main.id}"


  tags = {
    Name = "hp_gateway"
  }
}


#routing table
resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.main.id}"
  
  route {
    cider_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IGW.id}"
  }
  tags = {
   Name = "hproute"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Pub_subnet.id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pri_subnet.id
  route_table_id = aws_route_table.route_table.id
}


#Security group

resource "aws_security_group" "security" {
  name        = "hpsecurity"
  description = "Allow inbound traffic"
  vpc_id = "${aws_vpc.main.id}"


  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TCP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#AWS instance creation

resource "aws_instance" "myos1" {
	ami = "ami-052c08d70def0ac62"
	instance_type = "t2.micro"
	key_name = "key123"
	vpc_security_group_ids = [aws_security_group.security.id]
    subnet_id = "${aws_subnet.Pub_subnet.id}"
tags = {
	Name = "WPOS"
	}
   }
resource "aws_instance" "myos2" {
	ami = "ami-08706cb5f68222d09"
	instance_type = "t2.micro"
	key_name = "key123"
	vpc_security_group_ids = [aws_security_group.security.id]
     subnet_id = "${aws_subnet.pri_subnet.id}"
tags = {
	Name = "SQLOS"
	
   }
}