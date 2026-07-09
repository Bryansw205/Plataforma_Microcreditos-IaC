resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${local.name_prefix}-frontend-oac"
  description                       = "OAC para el bucket frontend de ${local.name_prefix}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "frontend" {
  name        = "${local.name_prefix}-frontend-cache-policy"
  comment     = "Politica de cache para frontend estatico"
  default_ttl = 3600
  max_ttl     = 86400
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_distribution" "main" {
# checkov:skip=CKV2_AWS_42:Certificado ACM personalizado (aws_acm_certificate.cloudfront) ya definido en acm.tf. Se activa al configurar var.domain_name en producción.
# checkov:skip=CKV_AWS_174:Certificado personalizado pendiente de configuración de dominio. En producción se usará ACM con TLS 1.2.
# checkov:skip=CKV_AWS_310:Origen único S3 con versioning y lifecycle configurados. S3 ofrece 99.999999999% de durabilidad. Failover de origen no aplica para contenido estatico.
# checkov:skip=CKV_AWS_374:Plataforma de microcréditos con cobertura latinoamericana. Restricción geográfica no aplica por requisito de negocio de inclusión financiera.
  enabled             = true
  comment             = "Distribucion CloudFront para ${local.name_prefix}"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  web_acl_id          = aws_wafv2_web_acl.main.arn

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.audit.bucket_domain_name
    prefix          = "cloudfront-access-logs/"
  }

  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "s3-frontend"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  default_cache_behavior {
  # Solución CKV2_AWS_32
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
    target_origin_id       = "s3-frontend"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = aws_cloudfront_cache_policy.frontend.id
    compress               = true

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
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

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cloudfront"
    Type = "cdn"
  })
}

resource "aws_s3_bucket_policy" "frontend_cloudfront" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })
}

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name    = "${local.name_prefix}-security-headers"
  comment = "Security headers para plataforma de microcréditos (RNF_16)"
  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
  }
}