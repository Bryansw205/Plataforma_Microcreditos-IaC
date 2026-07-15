# CloudWatch Observability Dashboard

resource "aws_cloudwatch_dashboard" "observability" {
  dashboard_name = "${local.name_prefix}-observability"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2
        properties = {
          markdown = "# Plataforma de Microcréditos - Dashboard de Observabilidad\nMonitoreo en tiempo real de los 4 atributos de calidad más críticos: **Rendimiento**, **Disponibilidad**, **Tolerancia a fallos** y **Escalabilidad**."
        }
      },

      # 1. RENDIMIENTO
      {
        type   = "text"
        x      = 0
        y      = 2
        width  = 24
        height = 1
        properties = {
          markdown = "## Rendimiento - Latencia y eficiencia en transacciones"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 3
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.api.arn_suffix, { "stat" : "Average", "label" : "Latencia Promedio", "period" : 60 }],
            [".", ".", ".", ".", { "stat" : "p95", "label" : "Latencia p95", "period" : 60 }]
          ]
          region = var.aws_region
          title  = "Red (ALB): Latencia de Respuesta del Backend (Segundos)"
          view   = "timeSeries"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 3
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBClusterIdentifier", aws_rds_cluster.aurora.cluster_identifier, { "stat" : "Average", "label" : "Conexiones Activas", "period" : 60 }]
          ]
          region = var.aws_region
          title  = "Base de Datos (Aurora): Conexiones Activas de Clientes"
          view   = "timeSeries"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 3
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBClusterIdentifier", aws_rds_cluster.aurora.cluster_identifier, { "stat" : "Average", "label" : "CPU DB %", "period" : 60 }]
          ]
          region = var.aws_region
          title  = "Base de Datos (Aurora): Uso de CPU (%)"
          view   = "timeSeries"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },

      # 2. DISPONIBILIDAD
      {
        type   = "text"
        x      = 0
        y      = 9
        width  = 24
        height = 1
        properties = {
          markdown = "## Disponibilidad - Continuidad del servicio y salud del sistema"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 10
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.api.arn_suffix, { "stat" : "Sum", "label" : "Peticiones Totales", "period" : 60 }]
          ]
          region = var.aws_region
          title  = "Red (ALB): Volumen de Peticiones (Throughput)"
          view   = "timeSeries"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 10
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.api.name, { "stat" : "Average", "label" : "Tareas API", "period" : 60 }],
            ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.worker.name, { "stat" : "Average", "label" : "Tareas Worker", "period" : 60 }]
          ]
          region = var.aws_region
          title  = "Cómputo (ECS): Tareas Ejecutándose (ContainerInsights)"
          view   = "timeSeries"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 10
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", aws_lb_target_group.ecs_api.arn_suffix, "LoadBalancer", aws_lb.api.arn_suffix, { "stat" : "Average", "label" : "Hosts Saludables", "period" : 60 }],
            [".", "UnHealthyHostCount", ".", ".", ".", ".", { "stat" : "Average", "label" : "Hosts No Saludables", "color" : "#d13212", "period" : 60 }]
          ]
          region = var.aws_region
          title  = "Red (ALB): Salud de Instancias en Target Group"
          view   = "timeSeries"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      # 3. TOLERANCIA A FALLOS
      {
        type   = "text"
        x      = 0
        y      = 16
        width  = 24
        height = 1
        properties = {
          markdown = "## Tolerancia a Fallos - Gestión de errores y colas de descarte"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 17
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", aws_lb.api.arn_suffix, { "stat" : "Sum", "label" : "HTTP 2xx (Éxito)", "color" : "#2ca02c", "period" : 60 }],
            [".", "HTTPCode_Target_4XX_Count", ".", ".", { "stat" : "Sum", "label" : "HTTP 4xx (Error Cliente)", "color" : "#ff7f0e", "period" : 60 }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { "stat" : "Sum", "label" : "HTTP 5xx (Error Servidor)", "color" : "#d62728", "period" : 60 }]
          ]
          region = var.aws_region
          title  = "Red (ALB): Códigos de Respuesta HTTP del Target Group"
          view   = "timeSeries"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 17
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", aws_sqs_queue.processing_dlq.name, { "stat" : "Maximum", "label" : "Mensajes en DLQ", "color" : "#d62728", "period" : 60 }]
          ]
          region = var.aws_region
          title  = "Colas (SQS DLQ): Mensajes en Dead-Letter Queue (Cola de Fallos)"
          view   = "timeSeries"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      # 4. ESCALABILIDAD
      {
        type   = "text"
        x      = 0
        y      = 23
        width  = 24
        height = 1
        properties = {
          markdown = "## Escalabilidad - Capacidad de cómputo, memoria y carga de colas"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 24
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", aws_ecs_service.api.name, "ClusterName", aws_ecs_cluster.main.name, { "stat" : "Average", "label" : "API CPU %", "period" : 60 }],
            [".", ".", "ServiceName", aws_ecs_service.worker.name, "ClusterName", aws_ecs_cluster.main.name, { "stat" : "Average", "label" : "Worker CPU %", "period" : 60 }]
          ]
          region = var.aws_region
          title  = "Cómputo (ECS): Utilización de CPU (%)"
          view   = "timeSeries"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 24
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ServiceName", aws_ecs_service.api.name, "ClusterName", aws_ecs_cluster.main.name, { "stat" : "Average", "label" : "API Memoria %", "period" : 60 }],
            [".", ".", "ServiceName", aws_ecs_service.worker.name, "ClusterName", aws_ecs_cluster.main.name, { "stat" : "Average", "label" : "Worker Memoria %", "period" : 60 }]
          ]
          region = var.aws_region
          title  = "Cómputo (ECS): Utilización de Memoria (%)"
          view   = "timeSeries"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 24
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", aws_sqs_queue.processing.name, { "stat" : "Average", "label" : "Mensajes Visibles", "period" : 60 }],
            [".", "ApproximateNumberOfMessagesNotVisible", ".", ".", { "stat" : "Average", "label" : "Mensajes Procesando (In-Flight)", "period" : 60 }]
          ]
          region = var.aws_region
          title  = "Colas (SQS): Mensajes en Cola Principal"
          view   = "timeSeries"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      # 5. LOGS Y AUDITORÍA
      {
        type   = "text"
        x      = 0
        y      = 30
        width  = 24
        height = 1
        properties = {
          markdown = "## Logs de Aplicación e Infraestructura - Registro centralizado"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 31
        width  = 12
        height = 6
        properties = {
          query         = "fields @timestamp, @message, @logStream | filter @message like /(?i)(error|fail|warn|exception)/ | sort @timestamp desc | limit 50"
          region        = var.aws_region
          title         = "Aplicación (ECS API Logs): Errores y Advertencias"
          view          = "table"
          logGroupNames = [aws_cloudwatch_log_group.ecs_api.name]
        }
      },
      {
        type   = "log"
        x      = 12
        y      = 31
        width  = 12
        height = 6
        properties = {
          query         = "fields @timestamp, @message, @logStream | filter @message like /(?i)(error|fail|warn|process|start|complete)/ | sort @timestamp desc | limit 50"
          region        = var.aws_region
          title         = "Aplicación (ECS Worker Logs): Tareas y Mensajes de Procesamiento"
          view          = "table"
          logGroupNames = [aws_cloudwatch_log_group.ecs_worker.name]
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 37
        width  = 12
        height = 6
        properties = {
          query         = "fields @timestamp, @message | filter @message like /(?i)(alter|drop|create|duration|statement|error|fatal)/ | sort @timestamp desc | limit 50"
          region        = var.aws_region
          title         = "Base de Datos (Aurora PostgreSQL Logs): Auditoría DDL y Errores"
          view          = "table"
          logGroupNames = ["/aws/rds/cluster/${aws_rds_cluster.aurora.cluster_identifier}/postgresql"]
        }
      },
      {
        type   = "log"
        x      = 12
        y      = 37
        width  = 12
        height = 6
        properties = {
          query         = "fields @timestamp, eventName, eventSource, userIdentity.arn, errorCode, errorMessage | sort @timestamp desc | limit 50"
          region        = var.aws_region
          title         = "Auditoría e Infraestructura (AWS CloudTrail Logs): Eventos de API"
          view          = "table"
          logGroupNames = [aws_cloudwatch_log_group.cloudtrail.name]
        }
      }
    ]
  })
}
