# ============================================================
# Plataforma de Microcréditos - Infraestructura como Código
# Bloque Base e Inicialización
# ============================================================
#
# Este archivo funciona como módulo raíz del proyecto.
# Desde aquí se conectarán los módulos de infraestructura.
#
# Parte actual:
# - Configuración base de Terraform
# - Configuración del proveedor AWS
# - Variables generales del proyecto
#
# Parte posterior:
# - Módulo compute: ALB + ECS Fargate
# ============================================================

data "aws_region" "current" {}

# El módulo compute se conectará después, cuando se implemente:
#
# module "compute" {
#   source = "./modules/compute"
#
#   project_name    = var.project_name
#   environment     = var.environment
#   name_prefix     = local.name_prefix
#   app_port        = var.app_port
#   container_image = var.container_image
# }