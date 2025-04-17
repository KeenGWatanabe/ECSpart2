# High availability NAT gateways (one per AZ)
resource "aws_eip" "nat" {
  count = 2
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "rger-flask-nat-${count.index}"
  }
}

# AZ-specific private route tables
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "rger-flask-private-rt-${count.index}"
  }
}