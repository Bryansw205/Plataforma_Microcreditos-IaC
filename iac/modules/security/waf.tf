resource "aws_wafv2_ip_set" "regional_blocked_ips" {
  count = var.enable_regional_waf && var.enable_ip_block_rule && length(var.blocked_ip_addresses) > 0 ? 1 : 0

  name               = "${local.name_prefix}-regional-blocked-ips"
  description        = "Blocked IP addresses for regional resources"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blocked_ip_addresses

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-regional-blocked-ips"
  })
}

resource "aws_wafv2_web_acl" "regional" {
  count = var.enable_regional_waf ? 1 : 0

  name        = "${local.name_prefix}-regional-waf"
  description = "Regional WAF for Application Load Balancer"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = var.enable_ip_block_rule && length(var.blocked_ip_addresses) > 0 ? [1] : []

    content {
      name     = "block-listed-ips"
      priority = 0

      action {
        block {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.regional_blocked_ips[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name_prefix}-regional-blocked-ips"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.enable_rate_limit_rule ? [1] : []

    content {
      name     = "rate-limit-by-ip"
      priority = 1

      action {
        block {}
      }

      statement {
        rate_based_statement {
          limit                 = var.rate_limit_requests
          aggregate_key_type    = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name_prefix}-regional-rate-limit"
        sampled_requests_enabled   = true
      }
    }
  }

  rule {
    name     = "aws-common-rule-set"
    priority = 10

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
      metric_name                = "${local.name_prefix}-regional-common-rules"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-known-bad-inputs-rule-set"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-regional-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-sqli-rule-set"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-regional-sqli"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-regional-waf"
    sampled_requests_enabled   = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-regional-waf"
  })
}

resource "aws_wafv2_ip_set" "cloudfront_blocked_ips" {
  provider = aws.us_east_1

  count = var.enable_cloudfront_waf && var.enable_ip_block_rule && length(var.blocked_ip_addresses) > 0 ? 1 : 0

  name               = "${local.name_prefix}-cloudfront-blocked-ips"
  description        = "Blocked IP addresses for CloudFront"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.blocked_ip_addresses

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cloudfront-blocked-ips"
  })
}

resource "aws_wafv2_web_acl" "cloudfront" {
  provider = aws.us_east_1

  count = var.enable_cloudfront_waf ? 1 : 0

  name        = "${local.name_prefix}-cloudfront-waf"
  description = "Global WAF for CloudFront"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = var.enable_ip_block_rule && length(var.blocked_ip_addresses) > 0 ? [1] : []

    content {
      name     = "block-listed-ips"
      priority = 0

      action {
        block {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.cloudfront_blocked_ips[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name_prefix}-cloudfront-blocked-ips"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.enable_rate_limit_rule ? [1] : []

    content {
      name     = "rate-limit-by-ip"
      priority = 1

      action {
        block {}
      }

      statement {
        rate_based_statement {
          limit                 = var.rate_limit_requests
          aggregate_key_type    = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name_prefix}-cloudfront-rate-limit"
        sampled_requests_enabled   = true
      }
    }
  }

  rule {
    name     = "aws-common-rule-set"
    priority = 10

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
      metric_name                = "${local.name_prefix}-cloudfront-common-rules"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-known-bad-inputs-rule-set"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-cloudfront-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-sqli-rule-set"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-cloudfront-sqli"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-cloudfront-waf"
    sampled_requests_enabled   = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cloudfront-waf"
  })
}
# Logging for Regional WAF
resource "aws_cloudwatch_log_group" "regional_waf" {
  count             = var.enable_regional_waf ? 1 : 0
  name              = "aws-waf-logs-${local.name_prefix}-regional"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.main.arn

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-regional-waf-logs"
  })
}

resource "aws_wafv2_web_acl_logging_configuration" "regional" {
  count = var.enable_regional_waf ? 1 : 0

  log_destination_configs = [aws_cloudwatch_log_group.regional_waf[0].arn]
  resource_arn            = aws_wafv2_web_acl.regional[0].arn
}

# Logging for CloudFront WAF
resource "aws_cloudwatch_log_group" "cloudfront_waf" {
  provider = aws.us_east_1
  count    = var.enable_cloudfront_waf ? 1 : 0

  name              = "aws-waf-logs-${local.name_prefix}-cloudfront"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.main.arn

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cloudfront-waf-logs"
  })
}

resource "aws_wafv2_web_acl_logging_configuration" "cloudfront" {
  provider = aws.us_east_1
  count    = var.enable_cloudfront_waf ? 1 : 0

  log_destination_configs = [aws_cloudwatch_log_group.cloudfront_waf[0].arn]
  resource_arn            = aws_wafv2_web_acl.cloudfront[0].arn
}
