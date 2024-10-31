#setup aws provider
#1. access_key, 2. secret_key
variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type = string
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type = string
}

provider "aws" {
  region                  = "us-east-2"
  access_key             = var.aws_access_key_id
  secret_key             = var.aws_secret_access_key
}


#Create a Security Group 
#inbound: port 80 (HTTP)
#egress: -1 (anything)

resource "aws_security_group" "nginx_sg"{
    name = "nginx_sg"
    description = "Allow HTTP inbound traffic"

    ingress {
        description = "Allow HTTP"

        #range of ports for ingress (only use port 80)
        from_port = 80
        to_port = 80

        #protocol that needs to be followed
        #TCP is usually used for http
        #more reliable rather than UDP 
        #(more used for real time applications rather than web traffic)
        protocol = "tcp"

        #allowing any IP to access
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        #0 to 0 means any port allowed
        from_port = 0
        to_port = 0

        #any protocol (-1)
        protocol = "-1"

        #allowing any IP to access
        cidr_blocks = ["0.0.0.0/0"]
    }
}


#Creating an EC2 Instance with Nginx Installation
resource "aws_instance" "nginx_instance" {
    # (Amazon machine image), tells the OS/configurations that'll be used
     #Ubuntu Linux
    ami = "ami-0ea3c35c5c3284d82"
    instance_type = "t2.micro"

    #attach security group
    vpc_security_group_ids = [aws_security_group.nginx_sg.id]

    #User data script for installing Nginx
    #systemctl start nginx to immediately let nginx handle HTTP requests (default page for now)
    #systemctl enable nginx -> sets Nginx  service to automatically boot whenever
    #EC2 instance restarts
    user_data = <<-EOF
            #!/bin/bash
            apt update -y
            apt install -y nginx
            systemctl start nginx
            systemctl enable nginx
        EOF

    tags = {
        Name="nginx-server"
    }
}

#Output the Public IP of the Instance
#output block is like print for terraform
output "nginx_instance_public_ip" {
    value = aws_instance.nginx_instance.public_ip
    description = "The public IP of the EC2 instance running Nginx"
}

