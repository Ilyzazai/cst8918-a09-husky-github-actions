terraform {
  required_version = ">= 1.2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource   "azurerm_resource_group"   "lab9" {
  name     = "rg-cst8918-a09-ilyas"
  location = "Canada Central"
}
