resource "aws_ecs_task_definition" "flask_xray" {
  family                   = "rger-flask-xray-taskdef"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    # Flask App Container
    {
      name      = "flask-app",
      image     = var.flask_image_uri,
      #image = "${var.ecr_repository_url}:latest"
      essential = true,
      portMappings = [{
        containerPort = 8080,
        protocol      = "tcp"
      }],
      environment = [
        { name = "SERVICE_NAME", value = "rger-flask-xray-service" }
      ],
      secrets = [
        { 
          name      = "MY_APP_CONFIG",
          valueFrom = "arn:aws:ssm:${var.region}:${var.account_id}:parameter/rgerapp/config"
        },
        {
          name      = "MY_DB_PASSWORD",
          valueFrom = "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:rgerapp/db_password"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          "awslogs-group"         = "/ecs/rger-flask-app",
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },
    # X-Ray Sidecar Container
    {
      name      = "xray-sidecar",
      image     = "amazon/aws-xray-daemon",
      essential = false,
      portMappings = [{
        containerPort = 2000,
        protocol      = "udp"
      }],
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          "awslogs-group"         = "/ecs/xray-sidecar",
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}