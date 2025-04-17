I'll help you modularize this setup with Terraform, including the **ECS Task Definition**, **SSM/Secrets Manager integration**, and **X-Ray sidecar**. Here's the complete solution:

---

### **1. Create a New Module: `modules/ecs-task`**
#### File: `modules/ecs-task/main.tf`
```terraform
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
```

#### File: `modules/ecs-task/variables.tf`
```terraform
variable "flask_image_uri" {
  description = "ECR URI for Flask app image"
  type        = string
}

variable "task_execution_role_arn" {
  description = "ARN of ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of ECS task role"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}
```

---

### **2. Update Your Root Module**
#### File: `main.tf`
```terraform
module "ecs_task" {
  source = "./modules/ecs-task"

  flask_image_uri         = "${aws_ecr_repository.flask.repository_url}:latest"
  task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn          = aws_iam_role.ecs_task_role.arn
  region                 = var.region
  account_id             = data.aws_caller_identity.current.account_id
}
```

---

### **3. Create Required AWS Resources**
#### File: `ecs.tf` (Add these if not existing)
```terraform
# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (for X-Ray and Secrets)
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "xray_write" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy" "secrets_access" {
  name = "secrets-manager-access"
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
```

---

### **4. Create SSM and Secrets Manager Entries**
```terraform
resource "aws_ssm_parameter" "app_config" {
  name  = "/rgerapp/config"
  type  = "String"
  value = "MySSMConfig"
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "rgerapp/db_password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = "P@ssw0rd"
}
```

---

### **5. Deploy**
```bash
terraform init
terraform apply
```

---

### **Key Features Added**
1. **Modular Task Definition** with:
   - Flask app container (port 8080)
   - X-Ray sidecar (port 2000 UDP)
   - SSM/Secrets Manager integration
2. **Least-Privilege IAM Roles**
3. **Centralized Configuration** via variables
4. **CloudWatch Logs** for both containers

Would you like me to add the ECS Service definition as well? I can include:
- Service auto-scaling
- Load balancer integration
- Deployment strategies (blue/green, rolling)