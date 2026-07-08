terraform {
<<<<<<< HEAD
  required_version = ">= 1.5.0"
=======
  required_version = ">= 1.6.0"
>>>>>>> 875d4ba (chore: Añadir archivos de variables de entorno para el entorno de desarrollo y el de producción)

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}