terraform {
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

module "vpc" {
  source = "./modules/vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  db_subnet_cidrs     = var.db_subnet_cidrs
  availability_zones  = var.availability_zones
  single_nat_gateway  = var.single_nat_gateway
  tags                = local.common_tags
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
  tags         = local.common_tags
}

module "rds" {
  source = "./modules/rds"

  project_name            = var.project_name
  db_subnet_ids           = module.vpc.db_subnet_ids
  db_security_group_id    = module.security.db_security_group_id
  db_name                 = var.db_name
  db_username             = var.db_username
  db_instance_class       = var.db_instance_class
  allocated_storage       = var.allocated_storage
  backup_retention_period = var.backup_retention_period
  multi_az                = var.multi_az
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  tags                    = local.common_tags
}

module "observability" {
  source = "./modules/observability"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  enable_guardduty          = var.enable_guardduty
  enable_security_hub       = var.enable_security_hub
  alert_email               = var.security_alert_email
  cloudtrail_retention_days = var.cloudtrail_retention_days
  tags                      = local.common_tags
}

module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_security_group_id
  access_log_bucket = module.observability.cloudtrail_bucket_name
  certificate_arn   = var.alb_certificate_arn
  tags              = local.common_tags
}

module "asg" {
  source = "./modules/asg"

  project_name          = var.project_name
  app_subnet_ids        = module.vpc.app_subnet_ids
  app_security_group_id = module.security.app_security_group_id
  alb_target_group_arn  = module.alb.target_group_arn
  instance_type         = var.instance_type
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.desired_capacity
  db_secret_arn         = module.rds.master_user_secret_arn
  db_secret_kms_key_arn = module.rds.db_kms_key_arn
  db_name               = var.db_name
  app_repository        = var.app_repository
  app_git_ref           = var.app_git_ref
  tags                  = local.common_tags
}
