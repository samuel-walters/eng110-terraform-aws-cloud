## Diagram

The below diagram details how Terraform and Ansible can be used to form IaC:

![](https://i.imgur.com/ubSImc9.png)

## Set Up Terraform

> 1. Set your environment variables. (In windows 11: `View Advanced System Settings`, and click
`Environment Variables`. Click `Add`, and fill in the values.)

> 2. Use these names: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

> 3. Create a file called `variable.tf`. Fill it in with sensitive information, following the below template:

```terraform
variable "NODE_AMI_ID" {
    default = "ami id will go here"
}
```

> 4. Do `nano main.tf` and type in these commands:

```terraform

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

# Create a Network ACL

resource "aws_network_acl" "sam-nacl" {
  vpc_id = aws_vpc.sam-vpc.id
  subnet_ids = ["${aws_subnet.sam-subnet.id}"]
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.NACL_CIDR_BLOCK
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.NACL_CIDR_BLOCK
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "sam-nacl"
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
```

> 5. Run `terraform init` in GitBash.

> 6. Then run `terraform plan` and then `terraform apply`. Check AWS for your newly created server.

> 7. Run `terraform destroy` to shut down the instance.

# Difference between pull and push configuration

![](https://i.imgur.com/H4gXedC.png)

There are two methods of IaC: ‘Push’ and ‘Pull’ . The main difference is the manner in which the servers are told how to be configured. In the Pull method the server to be configured will pull its configuration from the controlling server. In the Push method the controlling server pushes the configuration to the destination system.

IaC tools that use the pull model often have an agent running that polls a configuration management server for the latest desired state. If the current state does not match the desired state then the agent takes corrective action. This means that in a pull model the agent is effectively a continuous delivery system. The pull model is best suited for mutable (fried) infrastructure and can be used when you have full access to the systems you're managing. Baremetal desktops and virtual machines are good examples of such systems.

Tools that utilize the push model work differently. They are launched from a controller, which could be your own laptop or a CI/CD system like Jenkins. If the tool in question is declarative the controller reaches out to the systems being managed, then figures out the differences between desired state and current state and runs the commands required to reach the desired state. If the tool is imperative controller just runs commands it is told to or deploys a new pre-baked image. In any case the target systems do not need a dedicated agent to be running. The push model is often only choice when you only have limited (e.g. API) access to the system you're managing: this is the case with public Clouds and SaaS for example.

Terraform is a purely push model tool. This design choice was forced over it, though, because most of the systems it manages are only available through APIs.

In practice pull and push can be combined. For example, some Puppet providers use API calls to push changes to a remote or a local system. Yet those API calls might be triggered by a Puppet Agent that pulls it configurations from a puppetserver.



