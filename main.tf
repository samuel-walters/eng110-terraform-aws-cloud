# Create a script to initialise terraform to download dependencies required for AWS

# First step to create block of code to communicate with AWS
provider "aws" {
 region = "eu-west-1" 
}

# Launch a VPC
resource "aws_vpc" "sam-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "sam_vpc"
  }
}

# Launch a subnet

resource "aws_subnet" "sam-subnet" {
  vpc_id            = aws_vpc.sam-vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "eu-west-1a"

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
    cidr_blocks     = ["0.0.0.0/0"]   
  }

  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]  
  }

ingress {
    from_port       = "3000"
    to_port         = "3000"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]  
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1" 
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eng110-sam-sg-tf"
  }
}

# Key path
resource "aws_key_pair" "eng110_cicd_sam" {
  key_name = "eng110_cicd_sam"
  public_key = "${file(var.PUBLIC_KEY_PATH)}"
}

# Launch an ec2/server on aws
# Let terraform know which service/resource

resource "aws_instance" "app_instance" {
  # Choose an AMI to create ec2
  ami = "ami-0943382e114f188e8"
        # (ubuntu 18.04LTS)
  # What type of instance to launch
  instance_type = "t2.micro"
  # Key
  key_name = "eng119"
  # VPC
  subnet_id = "${aws_subnet.sam-subnet.id}"
  # Security group
  vpc_security_group_ids = ["${aws_security_group.sam-sg.id}"]
  # Do we want to have it globally available - public ip - attach yes or no?
  associate_public_ip_address = true
  # Name your instance
  tags = {Name = "eng110-sam-terraform-app"}

  # attach the file.pem
}