provider "aws" {
  region = var.region
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins port"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "jenkins_master" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "jenkins-master"
  }
}

resource "aws_instance" "jenkins_agents" {
  count                       = 2
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "jenkins-agent-${count.index + 1}"
  }
}
