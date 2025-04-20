# --- IAM Role for ECS Exec ---
resource "aws_iam_role" "ecs_exec_role" {
  name_prefix = "${local.prefix}-ecs-exec-role" #add random suffix

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
  lifecycle {
    create_before_destroy = true  # Helps with replacements
  }
}

resource "aws_iam_role_policy" "ecs_s3_access" {
  name_prefix = "${local.prefix}-s3-access"
  role = aws_iam_role.ecs_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::rgers3.tfstate-backend.com",
          "arn:aws:s3:::rgers3.tfstate-backend.com/*",
          "arn:aws:dynamodb:us-east-1:255945442255:table/terraform-state-locks"
        ]
      }
    ]
  })
  lifecycle {
    create_before_destroy = true  # Helps with replacements
  }
}

resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



output "ecs_exec_role_arn" {
  value = aws_iam_role.ecs_exec_role.arn  # Reference the actual IAM role resource
  description = "ARN of the ECS task execution IAM role"
}