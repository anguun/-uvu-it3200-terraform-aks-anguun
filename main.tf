data "azurerm_client_config" "current" {}

locals {
  suffix   = "uvu-it3200-${var.student_name}"
  acr_name = "acruvuit3200${var.student_name}"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.suffix}"
  location = var.location
}

# Private container registry (admin account off: access is through Entra / RBAC only)
resource "azurerm_container_registry" "main" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
}

# AKS: system-assigned managed identity, Entra ID integration, Azure RBAC for Kubernetes authorization
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${local.suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  dns_prefix          = "aks-${local.suffix}"

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
  }
}

# Part 3: the kubelet identity pulls images, so it gets AcrPull on the registry only.
resource "azurerm_role_assignment" "kubelet_acr_pull" {
  scope                            = azurerm_container_registry.main.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

# Your own account: needed to create the namespace and deploy the test app (Part 7).
# Remove this assignment when you are done testing.
resource "azurerm_role_assignment" "me_cluster_admin" {
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}
