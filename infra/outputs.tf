output "ecr_repository_url" {
  value = aws_ecr_repository.flask.repository_url
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
output "ecs_cluster_name" {
  value = aws_ecs_cluster.flask_xray_cluster.name
}

output "task_role_arn" {
  value = aws_iam_role.ecs_xray_task_role.arn
}

output "task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
