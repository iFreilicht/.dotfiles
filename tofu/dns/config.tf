# Tell terraform to use the provider and select a version.
terraform {
  required_providers {
    hetznerdns = {
      source = "timohirt/hetznerdns"
      version = "2.2.0"
    }
  }

  backend "local" {
    path = ".state/terraform.tfstate"
  }
}