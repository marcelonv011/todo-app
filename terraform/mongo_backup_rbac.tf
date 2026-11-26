resource "azurerm_role_assignment" "mongo_backup_upload" {
  scope = "/subscriptions/${var.subscription_id}/resourceGroups/rg-tudoapp-projetointegrador-backup/providers/Microsoft.Storage/storageAccounts/pm04bk504520/blobServices/default/containers/mongodb-backups"

  role_definition_name = "Storage Blob Data Contributor"

  principal_id   = azurerm_linux_virtual_machine.db.identity[0].principal_id
  principal_type = "ServicePrincipal"
}
