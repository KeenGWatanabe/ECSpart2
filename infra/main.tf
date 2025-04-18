

# modules/main.tf
module "vpc" {
  source = "./modules/vpc"
  region = var.region # Pass region to child modules
  app_name = var.app_name
}

module "ecs" {
  source             = "./modules/ecs"
  region             = var.region
  app_name           = var.app_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ecr_repository_url = aws_ecr_repository.flask.repository_url
  alb_security_group_id = aws_security_group.alb.id
  flask_image_uri = "${aws_ecr_repository.flask.repository_url}:latest"
  task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_xray_task_role.arn
  account_id = data.aws_caller_identity.current.account_id
}


# resource "aws_ecr_repository" "flask" {
#   name = "rger-flask-xray-repo"
  
#   # Optional but recommended:
#   image_tag_mutability = "MUTABLE"
#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }