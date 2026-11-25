terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Para la pipeline configuraremos este backend con Azure Blob Storage.
  # En la validación local usaremos: terraform init -backend=false
  backend "azurerm" {}
}
