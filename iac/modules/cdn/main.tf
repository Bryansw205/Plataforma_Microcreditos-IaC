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

# Data block removed due to IAM permissions (AccessDenied)
# data "aws_cloudfront_response_headers_policy" "security_headers" {
#   name = "Managed-SecurityHeadersPolicy"
# }

resource "aws_cloudfront_response_headers_policy" "frontend_security" {
  name    = "${var.project}-${var.environment}-frontend-security-headers"
  comment = "Cabeceras de seguridad para el frontend de la plataforma de microcreditos"

  security_headers_config {
    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    xss_protection {
      protection = true
      mode_block = true
      override   = true
    }
  }
}
resource "aws_cloudfront_distribution" "frontend" {
  #checkov:skip=CKV_AWS_310: Omitir failover de origen, ya que es un entorno de desarrollo/MVP y un unico bucket S3 es suficiente.
  #checkov:skip=CKV2_AWS_47: Se omite WAFv2 con regla Log4j para evitar sobrecostos. CloudFront sirve contenido estático y la arquitectura no utiliza Java, por lo que la mitigación no aplica.
  enabled             = true
  comment             = "${var.project}-${var.environment}-frontend-cdn"
  default_root_object = "index.html"
  price_class         = var.price_class
  aliases             = var.domain_aliases
  web_acl_id          = var.web_acl_id

  dynamic "logging_config" {
    for_each = var.log_bucket_domain_name != "" ? [1] : []
    content {
      include_cookies = false
      bucket          = var.log_bucket_domain_name
      prefix          = var.log_prefix
    }
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

    # Política personalizada de cabeceras de seguridad para CloudFront
    response_headers_policy_id = aws_cloudfront_response_headers_policy.frontend_security.id
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]

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
    ssl_support_method             = local.use_custom_domain ? "sni-only" : "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  # Solución por código para el error 374 (Restricción geográfica para el mercado de destino):
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["PE"] # Delimita el acceso al territorio peruano
    }
  }

  tags = {
    Name        = "${var.project}-${var.environment}-frontend-cdn"
    Project     = var.project
    Environment = var.environment
  }
}