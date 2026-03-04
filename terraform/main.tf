terraform {
  required_version = ">= 1.12.2"
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

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group
  location = var.location
}

# Stage 1 (initial run) 
# infrastructure ready if I need to use private link to hide the application URL
module "network" {
  source                        = "./modules/network"
  resource_group                = azurerm_resource_group.resource_group.name
  location                      = var.location
  virtual_network_name          = var.virtual_network_name
  virtual_network_address_space = var.virtual_network_address_space
  container_app_subnet_name     = var.container_app_subnet_name
  container_app_subnet_prefix   = var.container_app_subnet_prefix
}

module "az_container_registry" {
  source         = "./modules/az_container_registry"
  name           = "cntaskmanager"
  resource_group = azurerm_resource_group.resource_group.name
  location       = var.location
}

# Stage 2 (commented out to push docker image)
module "az_container_app" {
  source           = "./modules/az_container_app"
  app_name         = var.app_name
  env_name         = var.env_name
  resource_group   = azurerm_resource_group.resource_group.name
  location         = var.location
  container_name   = var.container_name
  acr_login_server = module.az_container_registry.acr_login_server
  image_tag        = var.image_tag
  identity_id      = module.role_assignment.identity_id
}

module "role_assignment" {
  source              = "./modules/role_assignment"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  identity_name       = "${var.app_name}-identity"
  scope               = module.az_container_registry.acr_id
}

module "front_door" {
  source             = "./modules/front_door"
  resource_group     = azurerm_resource_group.resource_group.name
  profile_name       = var.profile_name
  sku_name           = var.sku_name
  ep_name            = var.ep_name
  fd_group_name      = var.fd_group_name
  fd_origin_name     = var.fd_origin_name
  fd_route_name      = var.fd_route_name
  origin_host_name   = module.az_container_app.fqdn
  custom_name        = var.custom_name
  custom_domain_name = var.custom_domain_name
}
