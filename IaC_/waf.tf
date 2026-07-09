resource "aws_wafv2_web_acl" "main" {
  provider    = aws.us_east_1
  name        = "${local.name_prefix}-waf"
  description = "Web ACL para proteger el ALB de ${local.name_prefix}"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${replace(local.name_prefix, "-", "")}waf"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${replace(local.name_prefix, "-", "")}commonrules"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimit"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${replace(local.name_prefix, "-", "")}ratelimit"
      sampled_requests_enabled   = true
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-waf"
  })
}
