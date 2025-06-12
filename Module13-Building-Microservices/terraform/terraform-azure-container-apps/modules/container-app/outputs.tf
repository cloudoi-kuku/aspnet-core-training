# Outputs for Container App Module

output "id" {
  description = "ID of the container app"
  value       = azurerm_container_app.app.id
}

output "name" {
  description = "Name of the container app"
  value       = azurerm_container_app.app.name
}

output "latest_revision_name" {
  description = "Name of the latest revision"
  value       = azurerm_container_app.app.latest_revision_name
}

output "latest_revision_fqdn" {
  description = "FQDN of the latest revision"
  value       = azurerm_container_app.app.latest_revision_fqdn
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses of the container app"
  value       = azurerm_container_app.app.outbound_ip_addresses
}

output "custom_domain_verification_id" {
  description = "Custom domain verification ID"
  value       = azurerm_container_app.app.custom_domain_verification_id
}

output "url" {
  description = "Full URL of the container app"
  value       = var.enable_ingress ? "https://${azurerm_container_app.app.latest_revision_fqdn}" : ""
}