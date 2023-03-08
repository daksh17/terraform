
provider "aws" {

  region = "eu-central-1"
   access_key = "AKIASIBNDTD4FVBWQZHL"
  secret_key = "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"
}


variable "cidr_blocks" {}
variable "subnet_cidr_blocks" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location" {}


resource "aws_vpc" "daksh_vpc" {

  cidr_block = var.cidr_blocks
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}


resource "aws_subnet" "daksh_subnet_1" {

  vpc_id            = aws_vpc.daksh_vpc.id
  cidr_block        = var.subnet_cidr_blocks
  availability_zone = var.avail_zone
  tags = {
    Name : "${var.env_prefix}-subnet-1"
  }
}


resource "aws_internet_gateway" "daksh-internetgateway" {
  vpc_id = aws_vpc.daksh_vpc.id
  tags = {

    Name : "${var.env_prefix}-igw"
  }
}



resource "aws_default_route_table" "main_rtb" {

  default_route_table_id = aws_vpc.daksh_vpc.default_route_table_id

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



/* resource "aws_route_table_association" "daksh_rt_subnet_assoc"{

subnet_id = aws_subnet.daksh_subnet_1.id
route_table_id = aws_route_table.daksh-route-table.id

}*/



resource "aws_security_group" "daksh_sg" {

  name   = "daksh-sg"
  vpc_id = aws_vpc.daksh_vpc.id

  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]

  }


  ingress {

    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }



  egress {

    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []

  }

  tags = {

    Name : "${var.env_prefix}-sg"
  }

}





resource "aws_default_security_group" "daksh_default_sg" {

  # name   = "daksh-default-sg"
  vpc_id = aws_vpc.daksh_vpc.id

  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]

  }


  ingress {

    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }



  egress {

    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []

  }

  tags = {

    Name : "${var.env_prefix}-default-sg"
  }

}





data "aws_ami" "latest_aws_linux_image" {

most_recent= true 
owners = [137112412989]

filter {
  name = "name"
  values = ["amzn2-ami-*-gp2"]
}

filter {
  name = "virtualization-type"
  values = ["hvm"]
}

}



 output "aws_ami_id"{

  value = data.aws_ami.latest_aws_linux_image.image_id
}


 output "aws_ec2_publicIP"{

  value = aws_instance.daksh_instance.public_ip
  }


resource "aws_key_pair" "ssh_key"{

key_name = "server-key"
public_key = file(var.public_key_location)

}




 resource "aws_instance" "daksh_instance" {

  ami = data.aws_ami.latest_aws_linux_image.id
   instance_type = var.instance_type
   
   
   subnet_id = aws_subnet.daksh_subnet_1.id
   vpc_security_group_ids = [ aws_security_group.daksh_sg.id]

   availability_zone = var.avail_zone
   associate_public_ip_address = true
    key_name = aws_key_pair.ssh_key.key_name
   user_data =  file("entry-script.sh")

 
 tags = {

    Name : "${var.env_prefix}-default-inst"
    automation : "true"
  }

}

