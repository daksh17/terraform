
provider "aws" {

  region     = "eu-central-1"
 # access_key = "AKIASIBNDTD4FVBWQZHL"
  #secret_key = "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"
}




variable "cidr_blocks" {

  description= "subnet CIDR block and name tags for vpc and subnet "
  type = list(object({
    cidr_block = string
    name = string
  }))

}


variable AVAIL_ZONE{}


variable "enviornment" {

  description= "dev env deployment"

}




resource "aws_vpc" "daksh_vpc" {

  cidr_block = var.cidr_blocks[0].cidr_block
  tags = {

    Name : var.enviornment
    vpc_env : "dev"

  }
}


resource "aws_subnet" "daksh_subnet_1" {

  vpc_id            = aws_vpc.daksh_vpc.id
  cidr_block        = var.cidr_blocks[1].cidr_block
  availability_zone = var.AVAIL_ZONE
  tags = {
    Name : "subnet-1-dev"
  }
}

data "aws_vpc" "existing_vpc" {
  default = true


}

resource "aws_subnet" "daksh_subnet_2" {

  vpc_id            = data.aws_vpc.existing_vpc.id
  cidr_block        = "172.31.48.0/20"
  availability_zone = "eu-central-1a"
  tags = {
    Name : "subnet-default-dev"
  }
}


output "dev-subnet-id" {
  
  value= aws_subnet.daksh_subnet_1.id
}

output "dev-vpc-id" {
  
  value= aws_vpc.daksh_vpc.id
}