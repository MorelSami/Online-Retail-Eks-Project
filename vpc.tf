# Create a new Custom VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main_vpc"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "vpc_igw"
  }
}

# Create 2 Public and 2 Private Subnets

# Create 1st public subnet
resource "aws_subnet" "eks_pub_sub_one" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Pub Subnet One"
  }
}


# Create 2nd public subnet
resource "aws_subnet" "eks_pub_sub_two" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Pub Subnet two"
  }
}

# Create 1st private subnet
resource "aws_subnet" "eks_priv_sub_one" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet one"
  }
}

# Create 2nd private subnet
resource "aws_subnet" "eks_priv_sub_two" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet two"
  }
}

# Create an EIP for the NAT gateway
resource "aws_eip" "nat_eip" {
  #vpc = true  //deprecated
  domain = "vpc"
}


# Create NAT gateway
resource "aws_nat_gateway" "eks_nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.eks_pub_sub_one.id

  tags = {
    Name = "Natty GW"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.eks_igw]
}
