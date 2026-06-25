# ============================================================
# MODULE: networking (subnets.tf)
# Definición de subredes públicas y privadas (Multi-AZ)
# ============================================================

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  # SOLUCIÓN CKV_AWS_130: Desactivar asignación automática por defecto.
  # Protege la red impidiendo que recursos mal configurados expongan su IP a internet de nacimiento.
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${var.environment}-public-${var.availability_zones[count.index]}"
    Tier = "public"
  }
}

# Private Application Subnets
resource "aws_subnet" "private_app" {
  count = length(var.private_app_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-app-${var.availability_zones[count.index]}"
    Tier = "private-app"
  }
}

# Private Data Subnets
resource "aws_subnet" "private_data" {
  count = length(var.private_data_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_data_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-data-${var.availability_zones[count.index]}"
    Tier = "private-data"
  }
}