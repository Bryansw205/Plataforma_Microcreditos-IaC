resource "aws_cognito_user_group" "admin" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.main.id
  description  = "Administradores con acceso total a la aplicación"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-admin-group"
  })
}

resource "aws_cognito_user_group" "user" {
  name         = "user"
  user_pool_id = aws_cognito_user_pool.main.id
  description  = "Usuarios regulares con acceso limitado a la aplicación"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-user-group"
  })
}