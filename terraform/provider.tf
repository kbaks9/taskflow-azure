terraform {
  required_version = ">= 1.12.2"

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sataskmanagertfstate"
    container_name       = "tfstate"
    key                  = "taskmanager.terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.117.0"
    }
  }
}

provider "azurerm" {
  features {}
}

