resource "aws_security_group" "ecs" {
  name        = "${var.app_name}-ecs-sg"
  description = "ECS Service Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}