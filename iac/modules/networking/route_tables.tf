# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables
resource "aws_route_table" "private" {
  count  = var.enable_ha_nat ? length(var.availability_zones) : 1
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.enable_ha_nat ? "${var.project_name}-${var.environment}-private-rt-${count.index + 1}" : "${var.project_name}-${var.environment}-private-rt"
  }
}

resource "aws_route" "private_nat" {
  count = var.enable_ha_nat ? length(var.availability_zones) : 1

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}


resource "aws_route_table_association" "private_app" {
  count = length(var.private_app_subnet_cidrs)

  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = var.enable_ha_nat ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}

resource "aws_route_table_association" "private_data" {
  count = length(var.private_data_subnet_cidrs)

  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = var.enable_ha_nat ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}