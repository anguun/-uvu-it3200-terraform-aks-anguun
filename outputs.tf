output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "acr_name" {
  value = azurerm_container_registry.main.name
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "service_principal_client_id" {
  value = var.create_service_principal ? azuread_application.deploy[0].client_id : null
}

output "service_principal_object_id" {
  value = var.create_service_principal ? azuread_service_principal.deploy[0].object_id : null
}

output "service_principal_client_secret" {
  value     = var.create_service_principal ? azuread_application_password.deploy[0].value : null
  sensitive = true
}
