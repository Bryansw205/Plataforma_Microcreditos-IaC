locals {
  ecs_api_container_name    = "api"
  ecs_worker_container_name = "worker"

  api_container_image = var.api_image_uri != "" ? var.api_image_uri : "${aws_ecr_repository.api.repository_url}:latest"

  worker_container_image = var.worker_image_uri != "" ? var.worker_image_uri : "${aws_ecr_repository.worker.repository_url}:latest"
}

resource "aws_ecr_repository" "api" {
  name                 = "${local.name_prefix}-api"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.main.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-ecr"
    Type = "container-registry"
  })
}

resource "aws_ecr_repository" "worker" {
  name                 = "${local.name_prefix}-worker"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.main.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-worker-ecr"
    Type = "container-registry"
  })
}

resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-cluster"
    Type = "ecs-cluster"
  })
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${local.name_prefix}-api-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_api_cpu
  memory                   = var.ecs_api_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = local.ecs_api_container_name
      image     = local.api_container_image
      essential = true

      portMappings = [
        {
          containerPort = var.backend_port
          hostPort      = var.backend_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "PORT"
          value = tostring(var.backend_port)
        },
        {
          name  = "DB_HOST"
          value = aws_rds_cluster.aurora.endpoint
        },
        {
          name  = "DB_PORT"
          value = tostring(var.database_port)
        },
        {
          name  = "DB_NAME"
          value = aws_rds_cluster.aurora.database_name
        },
        {
          name  = "REDIS_HOST"
          value = aws_elasticache_replication_group.redis.primary_endpoint_address
        },
        {
          name  = "REDIS_PORT"
          value = tostring(var.redis_port)
        },
        {
          name  = "SQS_QUEUE_URL"
          value = aws_sqs_queue.processing.url
        },
        {
          name  = "DOCUMENTS_BUCKET"
          value = aws_s3_bucket.documents.bucket
        }
      ]

      secrets = [
        {
          name      = "DB_USERNAME"
          valueFrom = "${aws_rds_cluster.aurora.master_user_secret[0].secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_rds_cluster.aurora.master_user_secret[0].secret_arn}:password::"
        },
        {
          name      = "API_KEY_FLOW"
          valueFrom = "${aws_secretsmanager_secret.db_api_credenciales.arn}:api_key_flow::"
        },
        {
          name      = "API_KEY_INFOCORP"
          valueFrom = "${aws_secretsmanager_secret.db_api_credenciales.arn}:api_key_infocorp::"
        },
        {
          name      = "TASA_INTERES"
          valueFrom = aws_ssm_parameter.tasa_interes.arn
        },
        {
          name      = "LIMITE_CREDITOS"
          valueFrom = aws_ssm_parameter.limite_creditos.arn
        },
        {
          name      = "PLAZO_MAXIMO"
          valueFrom = aws_ssm_parameter.plazo_maximo.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_api.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "api"
        }
      }
    }
  ])

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-task"
    Type = "ecs-task-definition"
  })
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "${local.name_prefix}-worker-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_worker_cpu
  memory                   = var.ecs_worker_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = local.ecs_worker_container_name
      image     = local.worker_container_image
      essential = true
      command   = ["npm", "run", "start:worker"]

      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "DB_HOST"
          value = aws_rds_cluster.aurora.endpoint
        },
        {
          name  = "DB_PORT"
          value = tostring(var.database_port)
        },
        {
          name  = "DB_NAME"
          value = aws_rds_cluster.aurora.database_name
        },
        {
          name  = "REDIS_HOST"
          value = aws_elasticache_replication_group.redis.primary_endpoint_address
        },
        {
          name  = "REDIS_PORT"
          value = tostring(var.redis_port)
        },
        {
          name  = "SQS_QUEUE_URL"
          value = aws_sqs_queue.processing.url
        },
        {
          name  = "DOCUMENTS_BUCKET"
          value = aws_s3_bucket.documents.bucket
        }
      ]

      secrets = [
        {
          name      = "DB_USERNAME"
          valueFrom = "${aws_rds_cluster.aurora.master_user_secret[0].secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_rds_cluster.aurora.master_user_secret[0].secret_arn}:password::"
        },
        {
          name      = "API_KEY_FLOW"
          valueFrom = "${aws_secretsmanager_secret.db_api_credenciales.arn}:api_key_flow::"
        },
        {
          name      = "API_KEY_INFOCORP"
          valueFrom = "${aws_secretsmanager_secret.db_api_credenciales.arn}:api_key_infocorp::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_worker.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "worker"
        }
      }
    }
  ])

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-worker-task"
    Type = "ecs-task-definition"
  })
}

resource "aws_ecs_service" "api" {
  name                              = "${local.name_prefix}-api-service"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.api.arn
  desired_count                     = var.ecs_api_min_capacity
  launch_type                       = "FARGATE"
  platform_version                  = "LATEST"
  health_check_grace_period_seconds = var.ecs_health_check_grace_period_seconds
  enable_execute_command            = var.ecs_enable_execute_command

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = aws_subnet.private_app[*].id
    security_groups  = [aws_security_group.ecs_api.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_api.arn
    container_name   = local.ecs_api_container_name
    container_port   = var.backend_port
  }

  depends_on = [
    aws_lb_listener.https,
    aws_lb_listener.http_redirect,
    aws_lb_listener.http_forward
  ]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-service"
    Type = "ecs-service"
  })
}

resource "aws_ecs_service" "worker" {
  name                   = "${local.name_prefix}-worker-service"
  cluster                = aws_ecs_cluster.main.id
  task_definition        = aws_ecs_task_definition.worker.arn
  desired_count          = var.ecs_worker_min_capacity
  launch_type            = "FARGATE"
  platform_version       = "LATEST"
  enable_execute_command = var.ecs_enable_execute_command

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = aws_subnet.private_app[*].id
    security_groups  = [aws_security_group.ecs_worker.id]
    assign_public_ip = false
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-worker-service"
    Type = "ecs-service"
  })
}

resource "aws_appautoscaling_target" "api" {
  max_capacity       = var.ecs_api_max_capacity
  min_capacity       = var.ecs_api_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "api_cpu" {
  name               = "${local.name_prefix}-api-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.ecs_scale_cpu_threshold

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 120
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "api_memory" {
  name               = "${local.name_prefix}-api-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.ecs_scale_memory_threshold

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    scale_in_cooldown  = 120
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "worker" {
  max_capacity       = var.ecs_worker_max_capacity
  min_capacity       = var.ecs_worker_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "worker_queue_depth" {
  name               = "${local.name_prefix}-worker-queue-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.worker.resource_id
  scalable_dimension = aws_appautoscaling_target.worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.worker.service_namespace
  depends_on         = [aws_appautoscaling_target.worker]

  target_tracking_scaling_policy_configuration {
    target_value = var.ecs_worker_queue_messages_target

    customized_metric_specification {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      statistic   = "Average"

      dimensions {
        name  = "QueueName"
        value = aws_sqs_queue.processing.name
      }
    }

    scale_in_cooldown  = 180
    scale_out_cooldown = 60
  }
}