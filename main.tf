# 1. VPC Module
module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  region       = var.region
}

# 2. Security Groups Module
module "security" {
  source       = "./modules/security"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

# 3. Application Load Balancer Module
module "alb" {
  source            = "./modules/alb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}

# 4. RDS Database Module
module "rds" {
  source                = "./modules/rds"
  project_name          = var.project_name
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  db_sg_id              = module.security.db_sg_id
  db_name               = var.db_name
  db_user               = var.db_user
  db_password           = var.db_password
}

# 5. Auto Scaling Group & EC2 Module
module "asg" {
  source                 = "./modules/asg"
  project_name           = var.project_name
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  app_sg_id              = module.security.app_sg_id
  target_group_arn       = module.alb.target_group_arn
  db_host                = module.rds.db_endpoint
  db_user                = var.db_user
  db_password            = var.db_password
  db_name                = var.db_name
}