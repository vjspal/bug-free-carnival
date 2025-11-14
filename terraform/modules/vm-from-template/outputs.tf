output "vm_id" {
  description = "Proxmox VM ID"
  value       = proxmox_vm_qemu.vm.id
}

output "vm_name" {
  description = "VM name"
  value       = proxmox_vm_qemu.vm.name
}

output "ip_address" {
  description = "VM IP address"
  value       = var.ip_address
}
