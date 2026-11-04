# Parts 2 and 5. Off by default (create_service_principal = false).
# Needs permission to register Entra applications. Turn on with:
#   create_service_principal = true   (in terraform.tfvars)

resource "azuread_application" "deploy" {
  count        = var.create_service_principal ? 1 : 0
  display_name = "app-${local.suffix}"
}

resource "azuread_service_principal" "deploy" {
  count     = var.create_service_principal ? 1 : 0
  client_id = azuread_application.deploy[0].client_id
}

# Temporary client secret for this lab only. It is stored in Terraform state, so keep state private.
resource "azuread_application_password" "deploy" {
  count             = var.create_service_principal ? 1 : 0
  application_id    = azuread_application.deploy[0].id
  end_date_relative = "720h"
}

# Lets the identity run "az aks get-credentials".
resource "azurerm_role_assignment" "sp_cluster_user" {
  count                = var.create_service_principal ? 1 : 0
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_service_principal.deploy[0].object_id
}

# Read cluster resources (get nodes, namespaces).
resource "azurerm_role_assignment" "sp_rbac_reader" {
  count                = var.create_service_principal ? 1 : 0
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = azuread_service_principal.deploy[0].object_id
}

# Deploy workloads in ONE namespace only, no cluster-wide admin.
resource "azurerm_role_assignment" "sp_rbac_writer_ns" {
  count                = var.create_service_principal ? 1 : 0
  scope                = "${azurerm_kubernetes_cluster.main.id}/namespaces/${var.app_namespace}"
  role_definition_name = "Azure Kubernetes Service RBAC Writer"
  principal_id         = azuread_service_principal.deploy[0].object_id
}
