resource "aws_default_security_group" "daksh_default_sg" {

  # name   = "daksh-default-sg"
  vpc_id = var.vpc_id

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
  values = [var.image_name]
}

filter {
  name = "virtualization-type"
  values = ["hvm"]
}

}



resource "aws_key_pair" "ssh_key"{

key_name = "server-key"
public_key = file(var.public_key_location)

}




 resource "aws_instance" "daksh_instance" {

  ami = data.aws_ami.latest_aws_linux_image.id
   instance_type = var.instance_type
   


   
   subnet_id = var.subnet_id   // refrence the output of module daksh_subnet 

   vpc_security_group_ids = [ aws_default_security_group.daksh_default_sg.id ]

   availability_zone = var.avail_zone
   associate_public_ip_address = true
    key_name = aws_key_pair.ssh_key.key_name
   
   
   user_data =  file("./entry-script.sh")
/*
    connection { 

      type="ssh"
      host=self.public_ip
      user="ec2-user"
      private_key=file(var.private_key_location)

    }

    provisioner "file"{
      source = "entry-script.sh"
      destination = "/home/ec2-user/entry-script-on-ec2.sh"
    }

  provisioner "remote-exec" {
         script  = file("/home/ec2-user/entry-script-on-ec2.sh")
   
  }

  provisioner "local-exec"{
    command = "echo ${self.public_ip}> output.txt"
  }

*/
 tags = {

    Name : "${var.env_prefix}-default-inst"
    automation : "true"
  }

}

