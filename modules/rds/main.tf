# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name        = "${var.project_name}-db-subnet-group"
  subnet_ids  = var.db_subnet_ids
  description = "Subnet group for RDS"
  tags        = merge(var.tags, { Name = "${var.project_name}-db-subnet-group" })
}

# RDS MySQL Instance
resource "aws_db_instance" "mysql" {
  identifier     = "${var.project_name}-rds"
  engine         = "mysql"
  engine_version = "8.0.35"
  instance_class = var.db_instance_class
  allocated_storage = var.allocated_storage
  storage_type   = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_security_group_id]

  # ─── SECURITY & ENCRYPTION ───
  storage_encrypted = true
  kms_key_id        = var.kms_key_id

  # ─── BACKUPS ───
  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # ─── MULTI-AZ (CONTROLLED BY VARIABLE) ───
  multi_az = var.multi_az

  publicly_accessible = false

  # ─── FINAL SNAPSHOT ───
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.project_name}-final-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  tags = merge(var.tags, { Name = "${var.project_name}-rds" })
}