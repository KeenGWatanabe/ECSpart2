# modules/main.tf
module "vpc" {
  source = "./modules/vpc"
  # vpc_id = module.vpc.vpc_id  # Example of inter-module dependency
}

# module "ecs" {
#   source = "./modules/ecs"
  
# }