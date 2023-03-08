
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.cidr_blocks

  azs             = [var.avail_zone]
 # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = [var.subnet_cidr_blocks]

public_subnet_tags= { name = "${var.env_prefix}-subnet-1"}
  tags = {
    name = "${var.env_prefix}-vpc"
    Environment = "dev"
  }


}






module "daksh-server"{

source = "./modules/webservers"
 #subnet_cidr_blocks=var.subnet_cidr_blocks
 my_ip=var.my_ip
 env_prefix=var.env_prefix
 vpc_id= module.vpc.vpc_id
 image_name=var.image_name
 public_key_location=var.public_key_location
 instance_type=var.instance_type
 avail_zone=var.avail_zone
 #private_key_location=var.private_key_location
subnet_id = module.vpc.public_subnets[0]

}




