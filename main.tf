
resource "aws_vpc" "daksh_vpc" {

  cidr_block = var.cidr_blocks
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}


//call one module (subnet contain the terraform related ) in main.tf file and also make sure those variable which we need are define in main.tf which 

module "daksh-subnet"{

source = "./modules/subnet"
subnet_cidr_blocks  = var.subnet_cidr_blocks
avail_zone = var.avail_zone
env_prefix = var.env_prefix
vpc_id = aws_vpc.daksh_vpc.id
default_route_table_id=aws_vpc.daksh_vpc.default_route_table_id

}


//call one module (webserver contain the terraform related ) in main.tf file and also make sure those variable which we need are define in main.tf which 


module "daksh-server"{

source = "./modules/webservers"
 #subnet_cidr_blocks=var.subnet_cidr_blocks
 my_ip=var.my_ip
 env_prefix=var.env_prefix
 vpc_id= aws_vpc.daksh_vpc.id
 image_name=var.image_name
 public_key_location=var.public_key_location
 instance_type=var.instance_type
 avail_zone=var.avail_zone
 #private_key_location=var.private_key_location
subnet_id = module.daksh-subnet.web-subnet.id

}



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


