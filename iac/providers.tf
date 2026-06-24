provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Alias requerido por los módulos networking y security (WAF global)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}

# Alias requerido por los módulos auth y config
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}