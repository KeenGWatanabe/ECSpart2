# Add private subnets in different AZs
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 2}.0/24"  # Using 10.0.2.0/24 and 10.0.3.0/24
  availability_zone = "us-east-1${count.index == 0 ? "a" : "b"}"
  
  tags = {
    Name = "rger-flask-private-${count.index}"
  }
}

# Create NAT Gateway in public subnet (one per AZ or shared)
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id  # Using first public subnet

  tags = {
    Name = "rger-flask-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Private route table with NAT gateway route
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "rger-flask-private-rt"
  }
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private[0].id]  # Use 1 subnet per AZ
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
}

# Update VPC endpoints to include private subnets (optional but recommended)
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private[1].id]  # Different AZ than ECR endpoint
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
}
