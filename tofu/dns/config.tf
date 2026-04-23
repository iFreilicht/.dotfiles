# Tell terraform to use the provider and select a version.
terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.60.1"
    }
  }

  backend "local" {
    path = ".state/terraform.tfstate"
  }
}