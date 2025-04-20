resource "aws_ecs_task_definition" "flask_app_task" {
  family = "flask-app-xray-family"

  container_definitions = jsonencode([
    {
      "name"              : "flask-app",
      "image"             : "255945442255.dkr.ecr.us-east-1.amazonaws.com/rger-flask-xray:latest", // Your manually pushed image
      "memory"            : 512,
      "cpu"               : 256,
      "essential"         : true,
      "portMappings"      : [
        {
          "containerPort": 8080,
          "protocol"     : "tcp"
        }
      ],
      "environment" : [
        {
          "name"  : "SERVICE_NAME",
          "value" : "rger-flask-xray-service"
        }
      ],
      "secrets" : [
        {
          "name"      : "MY_APP_CONFIG",
          "valueFrom" : "arn:aws:ssm:us-east-1:255945442255:parameter/rgerapp/config"
        },
        {
          "name"      : "MY_DB_PASSWORD",
          "valueFrom" : "arn:aws:secretsmanager:us-east-1:255945442255:secret:rgerapp/db_password-LPmvuP"
        }
      ]
    },
    {
      "name"              : "xray-sidecar",
      "image"             : "amazon/aws-xray-daemon",
      "memory"            : 128,
      "cpu"               : 128,
      "essential"         : false,
      "portMappings"      : [
        {
          "containerPort": 2000,
          "protocol"     : "udp"
        }
      ],
      "logConfiguration": {
        "logDriver" : "awslogs",
        "options"   : {
          "awslogs-group"         : "/ecs/flask-app-xray",
          "awslogs-region"        : "us-east-1",
          "awslogs-stream-prefix" : "xray-sidecar"
        }
      }
    }
  ])
}

# Link Task Definition to ECS Services  
resource "aws_ecs_service" "flask_app_service" {
  name            = "flask-app-xray-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.flask_app_task.arn
  desired_count   = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.flask_app_task]
}
