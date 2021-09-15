provider "aws" {
  profile = "default"
  region  = "us-east-2"
}


resource "aws_security_group" "ubuntu" {
  name        = "ubuntu-security-group"
  description = "Allow HTTP, HTTPS and SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "terraform"
  }
}


resource "aws_instance" "ubuntu" {
  key_name      = "kriss"
  ami           = "ami-0b9064170e32bde34" # ubuntu 18.04 in us-east-2
  instance_type = "t2.micro"

  

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${file("~/coding/kriss.pem")}"
      host     = aws_instance.ubuntu.public_ip
      timeout     = "2m"
    }
    inline = [
    "sudo apt update",
    "sudo apt -y install python3-bs4 sshpass make",
    "sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
    "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
    "sudo apt update",
    "sudo apt install -y docker-ce docker-ce-cli containerd.io",
    "sudo usermod -aG docker $USER",
    #"su -s $USER",
    "docker swarm init",
    "docker network create -d overlay --subnet=10.10.0.0/24 --attachable testnet",
    "docker network ls",
    "docker network inspect testnet"
    #"sudo usermod -a -G docker ec2-user",
    #"sudo curl -L \"https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
    #"sudo chmod +x /usr/local/bin/docker-compose"  
    ]
  }

  tags = {
    Name = "krs-tf-nr1"
  }

  vpc_security_group_ids = [
    aws_security_group.ubuntu.id
  ]


}
//elastic IP
/*
resource "aws_eip" "ubuntu" {
  vpc      = true
  instance = aws_instance.ubuntu.id
}
*/