terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.47.0"
    }
  }
}
provider "aws" {
  access_key = "Your access key"
  secret_key = "Your secret key"
  region     = "eu-central-1"
}

resource "aws_key_pair" "deploy" {
  key_name   = "key"
  public_key = "ssh-rsa Your public key"

}
resource "aws_instance" "Docker_ubuntu2" {
  ami                    = "ami-05f7491af5eef733a"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.test_sg_for.id]
  key_name               = aws_key_pair.deploy.key_name
  user_data              = file("install_Docker.sh")
  tags = {
    Name = "Deploy_Server"
  }
}
# Create a new load balancer
resource "aws_elb" "test_elb" {
  name               = "elb"
  availability_zones = ["eu-central-1a", "eu-central-1c", "eu-central-1b"]

  listener {
    instance_port     = 8080
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  instances                   = [aws_instance.Docker_ubuntu2.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "terraform-elb"
  }
}

resource "aws_security_group" "test_sg_for" {
  name        = "Sg_for"
  description = "My first SG creating by terraform"
  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test_sg"
  }
}
output "elb_dns_name" {
  value       = aws_elb.test_elb.dns_name
  description = "DNS name of aws_elb"
}
output "instance_ip_addr" {
  value       = aws_instance.Docker_ubuntu2.public_ip
  description = "The public IP address of the main server instance."
}
