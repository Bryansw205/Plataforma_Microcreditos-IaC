# Módulo Security

Este módulo implementa la **Capa 2: Seguridad y Perímetro** de la infraestructura del proyecto de microcréditos.

Su responsabilidad es crear los controles principales de seguridad para proteger la arquitectura en AWS, sin crear recursos de red, base de datos, cómputo o almacenamiento. Los demás módulos consumen los outputs de esta capa.

## Recursos creados

Este módulo aprovisiona:

* Security Groups para ALB, backend, base de datos y Redis.
* Llave AWS KMS para cifrado de recursos críticos.
* AWS WAF regional para proteger el Application Load Balancer.
* AWS WAF global para proteger CloudFront.
* Reglas administradas de AWS WAF contra patrones comunes, entradas maliciosas e inyección SQL.
* Regla de rate limit para bloquear IPs con exceso de solicitudes.
* Regla opcional para bloquear manualmente IPs específicas.

## Relación con los RNF

Este módulo apoya principalmente los siguientes requerimientos no funcionales:

* RNF_14: cifrado en reposo de datos sensibles mediante AWS KMS.
* RNF_15: bloqueo temporal de IPs que superen el límite permitido de solicitudes.
* RNF_16: soporte de tráfico seguro hacia el ALB mediante puertos HTTP/HTTPS.
* RNF_18: reducción de exposición de infraestructura mediante aislamiento con Security Groups.

## Estructura del módulo

```text
iac/modules/security/
├── versions.tf
├── variables.tf
├── locals.tf
├── kms.tf
├── security_groups.tf
├── waf.tf
├── outputs.tf
└── README.md
```

## Entradas principales

| Variable                           | Descripción                                    |
| ---------------------------------- | ---------------------------------------------- |
| `project_name`                     | Nombre del proyecto.                           |
| `environment`                      | Ambiente de despliegue: dev, staging o prod.   |
| `vpc_id`                           | ID de la VPC creada por la capa de networking. |
| `backend_port`                     | Puerto del backend en ECS/Fargate.             |
| `database_port`                    | Puerto de PostgreSQL o Aurora.                 |
| `redis_port`                       | Puerto de Redis.                               |
| `allowed_http_cidr_blocks`         | CIDR permitidos para HTTP hacia el ALB.        |
| `allowed_https_cidr_blocks`        | CIDR permitidos para HTTPS hacia el ALB.       |
| `blocked_ip_addresses`             | Lista de IPs o rangos CIDR bloqueados por WAF. |
| `enable_regional_waf`              | Habilita WAF regional para ALB.                |
| `enable_cloudfront_waf`            | Habilita WAF global para CloudFront.           |
| `rate_limit_requests`              | Máximo de solicitudes permitidas por IP.       |
| `rate_limit_evaluation_window_sec` | Ventana de evaluación del rate limit.          |

## Outputs principales

| Output                       | Lo usa                                                     |
| ---------------------------- | ---------------------------------------------------------- |
| `alb_security_group_id`      | Módulo ALB                                                 |
| `backend_security_group_id`  | Módulo ECS/Fargate                                         |
| `database_security_group_id` | Módulo Aurora/RDS                                          |
| `redis_security_group_id`    | Módulo ElastiCache                                         |
| `kms_key_arn`                | Módulos de base de datos, SQS, SNS, Secrets, Logs y Backup |
| `regional_waf_web_acl_arn`   | Módulo ALB                                                 |
| `cloudfront_waf_web_acl_arn` | Módulo CloudFront                                          |

## Ejemplo de uso

```hcl
module "security" {
  source = "../../modules/security"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  project_name = var.project_name
  environment  = var.environment

  vpc_id       = module.network.vpc_id
  backend_port = 8080

  blocked_ip_addresses = []

  enable_regional_waf    = true
  enable_cloudfront_waf  = true
  enable_rate_limit_rule = true

  rate_limit_requests              = 20
  rate_limit_evaluation_window_sec = 60
}
```

## Consideraciones

AWS WAF no se despliega dentro de una subred ni dentro de la VPC. Se crea como una Web ACL y luego se asocia a recursos como CloudFront o Application Load Balancer.

El WAF regional protege recursos regionales como ALB.

El WAF global para CloudFront debe crearse usando un provider configurado en `us-east-1`.

La llave KMS creada por este módulo no cifra recursos por sí sola. Otros módulos deben consumir el output `kms_key_arn` para cifrar base de datos, colas, logs, secretos o almacenamiento.

## Seguridad aplicada

El tráfico permitido queda organizado así:

```text
Internet
→ ALB Security Group
→ Backend Security Group
→ Database Security Group
→ Redis Security Group
```

La base de datos solo acepta conexiones desde el backend.

Redis solo acepta conexiones desde el backend.

El backend solo acepta tráfico desde el ALB.

El ALB acepta tráfico HTTP/HTTPS desde los CIDR configurados.

```
```
