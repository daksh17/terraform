
resource "aws_subnet" "daksh_subnet_1" {

  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_blocks
  availability_zone = var.avail_zone
  tags = {
    Name : "${var.env_prefix}-subnet-1"
  }
}


resource "aws_internet_gateway" "daksh-internetgateway" {
  vpc_id = var.vpc_id
  tags = {

    Name : "${var.env_prefix}-igw"
  }
}


resource "aws_default_route_table" "main_rtb" {

  default_route_table_id = var.default_route_table_id

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.daksh-internetgateway.id
  }

  tags = {

    Name : "${var.env_prefix}main-rtb"
  }
}



/*

resource "aws_route_table" "daksh-route-table" {
  vpc_id = aws_vpc.daksh_vpc.id
  route{
    
    cidr_block="0.0.0.0/0"
    gateway_id = aws_internet_gateway.daksh-internetgateway.id
  }

  tags = {

    Name:"${var.env_prefix}-rtb"
  }
}

*/
