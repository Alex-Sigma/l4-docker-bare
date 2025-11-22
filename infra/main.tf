terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Лучше использовать aws configure / профили,
  # а не вписывать ключи в код
  region = "eu-north-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_key_pair" "mlops_key" {
  key_name   = "mlops-key"              # имя ключа на AWS
  public_key = file("~/.ssh/id_rsa.pub") # твой локальный публичный ключ
}

resource "aws_security_group" "mlops_sg" {
  name        = "mlops-sg"
  description = "Allow SSH and app port"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Порт приложения (FastAPI / Docker)
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Исходящий трафик – всё наружу разрешено
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mlops_ec2" {
  ami                    = "ami-04a5f55f5196f401f" # Ubuntu 22.04 LTS в eu-north-1
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.mlops_key.key_name
  vpc_security_group_ids = [aws_security_group.mlops_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "mlops-docker-instance"
  }

  # Устанавливаем Docker после старта инстанса
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",

      # Docker repo
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",

      # добавить пользователя ubuntu в группу docker
      "sudo usermod -aG docker ubuntu",

      # docker compose plugin (если понадобится)
      "sudo apt-get install -y docker-compose-plugin || true"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}

output "public_ip" {
  description = "Public IP of EC2 instance for Docker homework"
  value       = aws_instance.mlops_ec2.public_ip
}
