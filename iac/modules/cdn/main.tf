# ============================================================
# MODULE: cdn
# CloudFront para distribución segura del frontend estático
# ============================================================

locals {
  use_custom_domain = length(var.domain_aliases) > 0 && var.acm_certificate_arn != null
}

resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${var.project}-${var.environment}-frontend-oac"
  description                       = "OAC para restringir acceso directo al bucket frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# checkov:skip=CKV_AWS_310: Omitir failover de origen, ya que es un entorno de desarrollo/MVP y un unico bucket S3 es suficiente. :p
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  comment             = "${var.project}-${var.environment}-frontend-cdn"
  default_root_object = "index.html"
  price_class         = var.price_class
  aliases             = var.domain_aliases
  web_acl_id          = var.web_acl_id

  logging_config {
    include_cookies = false
    bucket          = var.log_bucket_domain_name # Ej: "mi-bucket-logs.s3.amazonaws.com"
    prefix          = var.log_prefix             # Ej: "cloudfront-frontend/"
  }

  origin {
    domain_name              = var.frontend_bucket_regional_domain_name
    origin_id                = "s3-${var.frontend_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-${var.frontend_bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  viewer_certificate {
    cloudfront_default_certificate = local.use_custom_domain ? false : true
    acm_certificate_arn            = local.use_custom_domain ? var.acm_certificate_arn : null
    ssl_support_method             = local.use_custom_domain ? "sni-only" : null
    minimum_protocol_version       = local.use_custom_domain ? "TLSv1.2_2021" : null
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "${var.project}-${var.environment}-frontend-cdn"
    Project     = var.project
    Environment = var.environment
  }
}