# Create a script to initialise terraform to download dependencies required for AWS

# First step to create block of code to communicate with AWS
provider "aws" {
 region = var.REGION_AWS
}

# Launch a VPC
resource "aws_vpc" "sam-vpc" {
  cidr_block       = var.VPC_CIDR
  instance_tenancy = "default"

  tags = {
    Name = "sam_vpc"
  }
}

# Launch a subnet

resource "aws_subnet" "sam-subnet" {
  vpc_id            = aws_vpc.sam-vpc.id
  cidr_block        = var.SUBNET_CIDR
  map_public_ip_on_launch = "true"
  availability_zone = var.AVAILABILITY_ZONE_AWS

  tags = {
    Name = "sam-subnet"
  }
}

# Internet gateway

resource "aws_internet_gateway" "sam-igw" {
    vpc_id = "${aws_vpc.sam-vpc.id}"
    tags = {
        Name = "sam-igw"
    }
}

# Route table

resource "aws_route_table" "sam-public-crt" {
    vpc_id = "${aws_vpc.sam-vpc.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.sam-igw.id}" 
    }
    
    tags = {
        Name = "sam-public-crt"
    }
}

# Associate CRT and Subnet

resource "aws_route_table_association" "sam-crta-public-subnet"{
    subnet_id = "${aws_subnet.sam-subnet.id}"
    route_table_id = "${aws_route_table.sam-public-crt.id}"
}


# Security group

resource "aws_security_group" "sam-sg"  {
  name = "eng110-sam-sg-tf"
  description = "eng110-sam-sg-tf"
  vpc_id = aws_vpc.sam-vpc.id

  ingress {
    from_port       = "80"
    to_port         = "80"
    protocol        = "tcp"
    cidr_blocks     = var.SECURITY_CIDR   
  }

  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    cidr_blocks     = var.SECURITY_CIDR  
  }

ingress {
    from_port       = var.SECURITY_PORT
    to_port         = var.SECURITY_PORT
    protocol        = "tcp"
    cidr_blocks     = var.SECURITY_CIDR  
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1" 
    cidr_blocks     = var.SECURITY_CIDR
  }

  tags = {
    Name = "eng110-sam-sg-tf"
  }
}

# Launch an ec2/server on aws
# Let terraform know which service/resource

resource "aws_instance" "app_instance" {
  # Choose an AMI to create ec2
  ami = var.NODE_AMI_ID
        # (ubuntu 18.04LTS)
  # What type of instance to launch
  instance_type = "t2.micro"
  # Key
  key_name = var.AWS_KEY_NAME
  # VPC
  subnet_id = "${aws_subnet.sam-subnet.id}"
  # Security group
  vpc_security_group_ids = ["${aws_security_group.sam-sg.id}"]
  # Do we want to have it globally available - public ip - attach yes or no?
  associate_public_ip_address = true
  # Name your instance
  tags = {Name = "eng110-sam-terraform-app"}
}