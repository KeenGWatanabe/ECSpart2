# Create ALB in public subnets
resource "aws_lb" "app" {
  name               = "flask-app-alb"
  internal           = false  # Public-facing
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id  # Public subnets
  security_groups    = [aws_security_group.alb.id]
}

# Target group for ECS tasks (port 8080)
resource "aws_lb_target_group" "app" {
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/health"  # Add a /health endpoint to your Flask app
  }
}

# ALB listener (HTTP → HTTPS redirect recommended)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}