# ==========================================
# AMI Amazon Linux 2023 (la plus récente)
# ==========================================
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ==========================================
# Security Group pour l'EC2
# ==========================================
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Security group for backend EC2 instance"
  vpc_id      = var.vpc_id

  # SSH depuis ton IP seulement
  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip_cidr]
  }

  # HTTP depuis Internet (pour Nginx reverse proxy)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS depuis Internet
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application NestJS (pour tests directs)
  ingress {
    description = "NestJS app from anywhere (testing)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tout le trafic sortant autorisé
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2-sg"
  })
}

# ==========================================
# Key Pair SSH
# ==========================================
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = file(var.ssh_public_key_path)

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-key"
  })
}

# ==========================================
# User Data : script qui s'exécute au démarrage
# ==========================================
locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e
    
    # Logs pour debug
    exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
    
    echo "Starting user-data script..."
    
    # Update système
    yum update -y
    
    # Installer Docker
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user
    
    # Installer Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Créer le répertoire de l'application
    mkdir -p /opt/learnmarket
    chown ec2-user:ec2-user /opt/learnmarket
    
    # Installer outils utiles
    yum install -y htop git
    
    # Installer Nginx
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    
    echo "User-data script completed!"
  EOF
}

# ==========================================
# Instance EC2 (t2.micro = Free Tier)
# ==========================================
resource "aws_instance" "backend" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = aws_key_pair.main.key_name
  
  user_data                   = local.user_data
  user_data_replace_on_change = false  # Ne pas recréer l'instance si user_data change
  
  # Root volume (30 GB free tier)
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }
  
  # IMDSv2 obligatoire (sécurité)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-backend"
  })
}

# ==========================================
# Elastic IP (IP fixe)
# ==========================================
resource "aws_eip" "backend" {
  instance = aws_instance.backend.id
  domain   = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-backend-eip"
  })
  
  depends_on = [aws_instance.backend]
}