resource "aws_cognito_user_pool" "main" {
  name = "${local.name_prefix}-usuarios"

  mfa_configuration = "ON"

  software_token_mfa_configuration {
    enabled = true
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  password_policy {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = var.password_require_symbols
    require_uppercase                = true
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    required                 = true
    mutable                  = false
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 5
      max_length = 254
    }
  }

  schema {
    name                     = "given_name"
    attribute_data_type      = "String"
    required                 = true
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 50
    }
  }

  schema {
    name                     = "family_name"
    attribute_data_type      = "String"
    required                 = true
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 50
    }
  }

  schema {
    name                     = "phone_number"
    attribute_data_type      = "String"
    required                 = false
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  dynamic "schema" {
    for_each = var.custom_attributes
    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.type
      required                 = schema.value.required
      mutable                  = schema.value.mutable
      developer_only_attribute = false
    }
  }

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  deletion_protection = "INACTIVE"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-usuarios"
  })

  depends_on = []
}


resource "aws_cognito_user_pool_domain" "main" {
  domain       = local.name_prefix
  user_pool_id = aws_cognito_user_pool.main.id
}
