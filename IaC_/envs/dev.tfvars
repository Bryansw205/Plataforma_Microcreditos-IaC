aws_region   = "us-east-1"
project_name = "microcreditos"
environment  = "dev"

vpc_cidr = "10.0.0.0/16"

backend_port  = 3000
database_port = 5432
redis_port    = 6379

alert_email = ""

aurora_deletion_protection     = false
alb_enable_deletion_protection = false