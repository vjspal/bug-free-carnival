# Proxmox Connection Variables
variable "proxmox_api_url" {
  description = "Proxmox API URL (e.g., https://192.168.1.200:8006/api2/json)"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API Token ID (e.g., root@pam!terraform)"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification (set true for self-signed certs)"
  type        = bool
  default     = true
}

# Proxmox Infrastructure Variables
variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "duality"
}

variable "proxmox_storage" {
  description = "Storage pool for VM disks"
  type        = string
  default     = "local-zfs"
}

variable "template_name" {
  description = "Name of the VM template created by Packer"
  type        = string
  default     = "ubuntu-2204-cloudinit-template"
}

# SSH Configuration
variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "ssh_user" {
  description = "Default SSH username for VMs"
  type        = string
  default     = "admin"
}

# Network Configuration
variable "network_bridge" {
  description = "Network bridge for VMs"
  type        = string
  default     = "vmbr0"
}

variable "network_gateway" {
  description = "Network gateway"
  type        = string
  default     = "192.168.1.1"
}

variable "dns_server" {
  description = "DNS server (use router until Pi-hole is deployed)"
  type        = string
  default     = "192.168.1.1"
}
