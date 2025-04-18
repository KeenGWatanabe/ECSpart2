provider "aws" {
  region = var.region  # Centralized region
  default_tags {
    tags = {
      Environment = "dev"
      Project    = "rger-app"
    }
  }
}