output "vm_password" {
  description = "The randomly generated password for the VM."
  value       = random_string.password.result
  sensitive   = true  # This makes sure the password is not shown in logs
}

output "vm_id" {
  description = "ID of the Azure Linux Virtual Machine"
  value       = azurerm_linux_virtual_machine.linux_machine.id
}

output "vm_ip" {
  description = "Public IP of the Linux Virtual Machine"
  value       = azurerm_network_interface.ni_linux.id
}
