terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.tags
  }
}

# ─── VPC MODULE ───
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  public_cidrs = var.public_subnet_cidrs
  app_cidrs    = var.app_subnet_cidrs
  db_cidrs     = var.db_subnet_cidrs
  azs          = var.availability_zones
  tags         = var.tags
}

# ─── SECURITY MODULE ───
module "security" {
  source = "./modules/security"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  # tags removed – security module may not accept tags
}

# --- RDS MODULE ---
module "rds" {
  source = "./modules/rds"

  project_name            = var.project_name
  db_subnet_ids           = module.vpc.db_subnet_ids
  db_security_group_id    = module.security.db_security_group_id
  db_name                 = var.db_name # ← This line is the problem
  db_username             = var.db_username
  db_password             = var.db_password
  db_instance_class       = var.db_instance_class
  allocated_storage       = 20
  backup_retention_period = 7
  multi_az                = false
  skip_final_snapshot     = true
  tags                    = var.tags
}
# --- ALB MODULE ---
module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_security_group_id
  tags              = var.tags
}

# ─── ASG MODULE ───
module "asg" {
  source = "./modules/asg"

  project_name          = var.project_name
  app_subnet_ids        = module.vpc.app_subnet_ids
  app_security_group_id = module.security.app_security_group_id
  alb_target_group_arn  = module.alb.target_group_arn
  instance_type         = "t3.micro"
  min_size              = 1
  max_size              = 2
  desired_capacity      = 1
  db_host               = module.rds.db_host
  db_user               = var.db_username
  db_password           = var.db_password
  db_name               = var.db_name
  tags                  = var.tags
}