# VPC Flow Logs
resource "aws_flow_log" "main" {
  vpc_id                = aws_vpc.main.id
  traffic_type          = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination       = var.flow_log_group_arn
  iam_role_arn          = var.flow_log_role_arn

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc-flow-logs"
  }
}