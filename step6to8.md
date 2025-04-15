Here's a Terraform configuration to create the IAM roles and ECS cluster as you've described:

```hcl
provider "aws" {
  region = "us-east-1"
}

# Create ECS Task Role with X-Ray write access
resource "aws_iam_role" "ecs_xray_task_role" {
  name = "rger-ecs-xray-taskrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "xray_write_access" {
  role       = aws_iam_role.ecs_xray_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# Create ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "rger-ecs-xray-taskexecutionrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_read_only" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_rw" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create ECS Cluster
resource "aws_ecs_cluster" "flask_xray_cluster" {
  name = "rger-flask-xray-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
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
```

This Terraform configuration will:

1. Create an IAM role named `rger-ecs-xray-taskrole` with the `AWSXRayDaemonWriteAccess` policy attached
2. Create an IAM role named `rger-ecs-xray-taskexecutionrole` with three policies attached:
   - `AmazonSSMReadOnlyAccess` (for accessing Parameter Store)
   - `SecretsManagerReadWrite` (for accessing Secrets Manager)
   - `AmazonECSTaskExecutionRolePolicy` (standard ECS execution policy)
3. Create an ECS Fargate cluster named `rger-flask-xray-cluster` with container insights enabled

To use this configuration:

1. Save it to a file (e.g., `ecs-setup.tf`)
2. Run `terraform init` to initialize the provider
3. Run `terraform plan` to see what will be created
4. Run `terraform apply` to create the resources

The outputs will show you the ARNs of the created roles and the cluster name, which you can use when defining your ECS task definitions later.