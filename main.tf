provider "aws" {
    profile = "default"
    region = "eu-west-3"
}

resource "aws_default_vpc" "main" {

  tags = { 
    Name = "main"
  }
}
resource "aws_key_pair" "deployer1" {
  key_name   = "deployer1"
  public_key = file("/root/.ssh/id_rsa.pub")
}

resource "aws_security_group" "aliaa-sec-group" {
  name        = "aliaa-sec-group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_default_vpc.main.id

  ingress {
    description      = "inbound rules from VPC"
   description      = "inbound rules from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_default_vpc.main.cidr_block]

  }

  ingress {
    description      = "inbound rules from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
  ingress {
    description      = "inbound rules from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws_security_group"
    instance_name = "aws_instance"
  }
}

resource "aws_instance" "web" {
    ami = "ami-0960de83329d12f2f"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.aliaa-sec-group.name]
    key_name = aws_key_pair.deployer1.key_name
    connection {
             type     = "ssh"
             user     = "ec2-user"
             host     = self.public_ip
             private_key = file("/root/.ssh/id_rsa")


            }

    provisioner "remote-exec" {
            inline = [
                "sudo yum install httpd",
                "sudo systemctl start httpd",
                "sudo systemctl enable httpd",

           ]
           }


    tags = {
            Name = "aliaa_webserver_terr"
          }
}