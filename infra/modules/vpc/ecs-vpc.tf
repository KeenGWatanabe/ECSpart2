# Add this to your configuration when ready
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "rger-flask-vpc"
  }
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = "us-east-1${count.index == 0 ? "a" : "b"}"
  
  tags = {
    Name = "rger-flask-public-${count.index}"
  }
}