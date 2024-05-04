# Create a route table for the private subnet
resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "My VPC Private Subnet Route Table"
  }
}


# Create a route table for the public subnet
resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "Public Subnet Route Table"
  }
}

# Create a route to the NAT gateway for the private subnet
resource "aws_route" "private_subnet_nat_gateway_route" {
  route_table_id         = aws_route_table.private_subnet_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks_nat_gw.id
}


# Create a route to the internet gateway for the public subnet
resource "aws_route" "public_subnet_internet_gateway_route" {
  route_table_id         = aws_route_table.public_subnet_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_igw.id
}


# Associate the 1st public subnet with the public subnet route table
resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id      = aws_subnet.eks_pub_sub_one.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}


# Associate the 2nd public subnet with the public subnet route table
resource "aws_route_table_association" "public_subnet_route_table_association_2" {
  subnet_id      = aws_subnet.eks_pub_sub_two.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

# Associate the 1st private subnet with the private subnet route table
resource "aws_route_table_association" "private_subnet_route_table_association" {
  subnet_id      = aws_subnet.eks_priv_sub_one.id
  route_table_id = aws_route_table.private_subnet_route_table.id
}


# Associate the 2nd private subnet with the private subnet route table
resource "aws_route_table_association" "private_subnet_route_table_association_2" {
  subnet_id      = aws_subnet.eks_priv_sub_two.id
  route_table_id = aws_route_table.private_subnet_route_table.id
}
