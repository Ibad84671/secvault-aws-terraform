# ==============================================================================
# LOAD BALANCER OUTPUTS
# ==============================================================================

output "alb_dns_name" {
  description = "The public DNS name of the Application Load Balancer to access the Flask web application"
  value       = module.alb.alb_dns_name
}

# ==============================================================================
# NETWORK (VPC) OUTPUTS
# ==============================================================================

output "vpc_id" {
  description = "The ID of the custom Amazon VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs for the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "List of IDs for the private application tier subnets"
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "List of IDs for the private database tier subnets"
  value       = module.vpc.private_db_subnet_ids
}

# ==============================================================================
# DATABASE (RDS) OUTPUTS
# ==============================================================================

output "rds_endpoint" {
  description = "The connection endpoint for the Amazon RDS MySQL instance"
  value       = module.rds.rds_endpoint
}

output "rds_address" {
  description = "The hostname address of the RDS instance"
  value       = module.rds.rds_address
}