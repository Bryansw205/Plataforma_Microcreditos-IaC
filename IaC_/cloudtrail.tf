resource "aws_cloudtrail" "main" {
  name                          = "${local.name_prefix}-audit-trail"
  s3_bucket_name                = aws_s3_bucket.audit.id
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  kms_key_id = aws_kms_key.main.arn
  sns_topic_name = aws_sns_topic.alerts.arn

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail.arn

  depends_on = [
    aws_s3_bucket_policy.audit
  ]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-audit-trail"
    Type = "cloudtrail"
  })
}
