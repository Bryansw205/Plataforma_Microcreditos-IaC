resource "aws_cognito_user_pool_client" "spa" {
  client_name = "${local.name_prefix}-cliente-spa"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",      
    "ALLOW_REFRESH_TOKEN_AUTH", 
  ]

  allow_admin_user_password_auth = var.allow_username_password_auth ? true : false

  supported_identity_providers = ["COGNITO"]

  allowed_oauth_flows = [
    "code", 
  ]

  allowed_oauth_scopes = [
    "openid",
    "email",
    "profile",
  ]

  allowed_oauth_flows_user_pool_client = true

  callback_urls =  
    [
      "https://${var.domain_name}/callback",
      "http://localhost:3000/callback",
    ]
  
  logout_urls = 
    [
      "https://${var.domain_name}",
      "http://localhost:3000",
    ]

  access_token_validity  = var.access_token_validity_minutes
  id_token_validity      = var.access_token_validity_minutes
  refresh_token_validity = var.refresh_token_validity_hours

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "hours"
  }

  prevent_user_existence_errors = "ENABLED"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cliente-spa"
    Type = "public"
  })
}

resource "aws_cognito_user_pool_client" "backend" {
  client_name = "${local.name_prefix}-cliente-backend"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = true


  explicit_auth_flows = [
    "ALLOW_ADMIN_NO_SRP_AUTH", 
    "ALLOW_REFRESH_TOKEN_AUTH", 
  ]

  allow_admin_user_password_auth = true

  access_token_validity  = var.access_token_validity_minutes
  id_token_validity      = var.access_token_validity_minutes
  refresh_token_validity = var.refresh_token_validity_hours

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "hours"
  }

  prevent_user_existence_errors = "ENABLED"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cliente-backend"
    Type = "confidential"
  })
}
