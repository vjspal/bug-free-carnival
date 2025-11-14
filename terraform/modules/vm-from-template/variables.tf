variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "target_node" {
  description = "Proxmox node to create VM on"
  type        = string
}

variable "template_name" {
  description = "Name of template to clone from"
  type        = string
}

variable "description" {
  description = "VM description"
  type        = string
  default     = ""
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Amount of RAM in MB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Disk size (e.g., '20G')"
  type        = string
  default     = "20G"
}

variable "storage" {
  description = "Storage pool"
  type        = string
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
}

variable "ip_address" {
  description = "Static IP address for the VM"
  type        = string
}

variable "gateway" {
  description = "Network gateway"
  type        = string
}

variable "nameserver" {
  description = "DNS nameserver"
  type        = string
}

variable "ssh_keys" {
  description = "SSH public keys"
  type        = string
}
