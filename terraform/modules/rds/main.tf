# ==========================================
# Security Group pour RDS
# Accepte les connexions UNIQUEMENT depuis EC2
# ==========================================
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-rds-sg"
  })
}

# ==========================================
# Subnet group (RDS doit être dans au moins 2 AZ)
# ==========================================
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet"
  })
}

# ==========================================
# Mot de passe sécurisé généré aléatoirement
# ==========================================
resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "_-=+"
}

# ==========================================
# Stockage du password dans Secrets Manager
# ==========================================
resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.project_name}/${var.environment}/db-password"
  description = "PostgreSQL password for ${var.environment}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-password"
  })
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

# ==========================================
# Instance RDS PostgreSQL (Free Tier)
# ==========================================
resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-${var.environment}"
  
  # Engine
  engine         = "postgres"
  engine_version = var.postgres_version
  instance_class = var.instance_class  # db.t3.micro = Free Tier
  
  # Storage
  allocated_storage     = var.allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  
  # Database
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  
  # Network
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  publicly_accessible    = false
  
  # High Availability (off pour Free Tier)
  multi_az = false
  
  # Backups
  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  
  # Suppression
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection
  
  # Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql"]
  performance_insights_enabled    = false  # Pas dispo en Free Tier sur db.t3.micro
  
  # Auto minor version upgrade
  auto_minor_version_upgrade = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db"
  })
}