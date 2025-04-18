provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = "rger-flask-app"
      ManagedBy   = "Terraform"
    }
  }
}

