aws_region  = "us-east-1"
project_name = "microcreditos"
environment = "dev"

vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

allowed_http_cidr = "0.0.0.0/0"

backend_container_port = 3000

enable_nat_gateway = false