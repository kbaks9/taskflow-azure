terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sataskmanagertfstate"
    container_name       = "tfstate"
    key                  = "taskflow-azure.terraform.tfstate"
  }
}
