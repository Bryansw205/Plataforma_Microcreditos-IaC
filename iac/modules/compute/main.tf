# ─────────────────────────────────────────────────────────
# IAM Roles para ECS
# ─────────────────────────────────────────────────────────

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name_prefix}-ecs-task-execution-role"

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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Permisos para leer de SSM y Secrets Manager (RNF_25)
resource "aws_iam_policy" "ecs_secrets_access" {
  name = "${var.name_prefix}-ecs-secrets-access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = [
          "arn:aws:ssm:*:*:parameter/${var.name_prefix}/*",
          "arn:aws:secretsmanager:*:*:secret:${var.name_prefix}-*",
          var.secrets_kms_key_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_secrets_access_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_secrets_access.arn
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name_prefix}-ecs-task-role"

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

# ─────────────────────────────────────────────────────────
# ECS Cluster
# ─────────────────────────────────────────────────────────

resource "aws_ecs_cluster" "main" {
  name = "${var.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled" # RNF_26
  }

  tags = {
    Name        = "${var.name_prefix}-cluster"
    Environment = var.environment
  }
}

# ─────────────────────────────────────────────────────────
# CloudWatch Log Group para el contenedor
# ─────────────────────────────────────────────────────────
# checkov:skip=CKV_AWS_338: Se define retención de 90 días para mitigar sobrecostos de almacenamiento en CloudWatch. El RNF_28 de observabilidad opera sobre eventos en tiempo real.
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.name_prefix}-app"
  retention_in_days = 30
  kms_key_id        = var.secrets_kms_key_arn # Reusamos KMS para encriptar logs
}

# ─────────────────────────────────────────────────────────
# ECS Task Definition (Fargate)
# ─────────────────────────────────────────────────────────

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name_prefix}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.name_prefix}-app-container"
      image     = var.ecr_image_uri
      essential = true
      
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      
      # Inyección dinámica de variables de entorno de ejemplo (RNF_25)
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        }
      ]
      
      # Referencias a Secrets y SSM (Requieren los ARNs reales en prod)
      # secrets = [
      #   {
      #     name      = "DATABASE_URL"
      #     valueFrom = "arn:aws:ssm:region:account-id:parameter/${var.name_prefix}/config/database_url"
      #   }
      # ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.name_prefix}-task-def"
    Environment = var.environment
  }
}

# ─────────────────────────────────────────────────────────
# ECS Service
# ─────────────────────────────────────────────────────────

resource "aws_ecs_service" "app" {
  name            = "${var.name_prefix}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  
  desired_count   = var.environment == "prod" ? 2 : 1

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "${var.name_prefix}-app-container"
    container_port   = var.container_port
  }

  # Permitir que Autoscaling maneje el desired_count sin interferir con Terraform
  lifecycle {
    ignore_changes = [desired_count]
  }
}
