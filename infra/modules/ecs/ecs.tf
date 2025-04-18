data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "secrets_access" {
  name = "rger-secrets-access"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["secretsmanager:GetSecretValue"],
      Effect   = "Allow",
      Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:rgerapp/db_password*"
    }]
  })
}