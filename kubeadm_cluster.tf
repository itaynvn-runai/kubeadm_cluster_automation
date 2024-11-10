provider "aws" {
  region = "us-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "instance_type" {
  default = "t2.medium" # Update instance type as needed
}

# Create VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "k8s_vpc"
  }
}

# Create Subnet
resource "aws_subnet" "k8s_subnet" {
  vpc_id     = aws_vpc.k8s_vpc.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "k8s_subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "k8s_igw"
  }
}

# Create Route Table
resource "aws_route_table" "k8s_route_table" {
  vpc_id = aws_vpc.k8s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }
  tags = {
    Name = "k8s_route_table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "k8s_route_table_assoc" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.k8s_route_table.id
}

# Security Group for Control Plane and Worker
resource "aws_security_group" "k8s_sg" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "k8s_sg"
  }

  # Allow SSH
  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Allow Kubernetes API (6443)
  ingress {
    description      = "Allow Kubernetes API"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Allow all egress
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# Create EC2 instance for Control Plane
resource "aws_instance" "control_plane" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (update with a compatible AMI)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.k8s_subnet.id
  security_groups = [aws_security_group.k8s_sg.name]
  tags = {
    Name = "k8s-control-plane"
  }
}

# Create EC2 instance for Worker Node
resource "aws_instance" "worker_node" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (update with a compatible AMI)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.k8s_subnet.id
  security_groups = [aws_security_group.k8s_sg.name]
  tags = {
    Name = "k8s-worker-node"
  }
}
