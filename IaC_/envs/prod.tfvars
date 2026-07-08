aws_region  = "us-east-1"
project_name = "microcreditos"
environment = "prod"

vpc_cidr = "10.1.0.0/16"

public_subnet_cidrs = [
  "10.1.1.0/24",
  "10.1.2.0/24"
]

private_subnet_cidrs = [
  "10.1.11.0/24",
  "10.1.12.0/24"
]

allowed_http_cidr = "0.0.0.0/0"

backend_container_port = 3000

enable_nat_gateway = true