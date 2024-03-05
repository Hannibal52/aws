
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }

}

provider "aws" {
  region = var.region
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
provider "kubernetes" {
  config_path    = "~/.kube/config"  # Assurez-vous que ce chemin mène à un fichier kubeconfig valide.
}


data "aws_availability_zones" "available" {}
