# Tell terraform to use the provider and select a version.
terraform {
  required_providers {
    hetznerdns = {
      source = "germanbrew/hetznerdns"
      version = "3.4.0"
    }
  }

  backend "local" {
    path = ".state/terraform.tfstate"
  }
}