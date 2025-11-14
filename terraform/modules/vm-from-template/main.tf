resource "proxmox_vm_qemu" "vm" {
  name        = var.vm_name
  target_node = var.target_node
  desc        = var.description

  # Clone from template
  clone = var.template_name

  # VM Resources
  cores   = var.cores
  sockets = var.sockets
  memory  = var.memory

  # Enable QEMU agent
  agent = 1

  # Boot configuration
  boot    = "order=scsi0"
  scsihw  = "virtio-scsi-pci"
  os_type = "cloud-init"

  # Disk configuration
  disk {
    slot    = 0
    size    = var.disk_size
    type    = "scsi"
    storage = var.storage
    # iothread = 1
  }

  # Network configuration
  network {
    model  = "virtio"
    bridge = var.network_bridge
  }

  # Cloud-init configuration
  ipconfig0 = "ip=${var.ip_address}/24,gw=${var.gateway}"

  nameserver = var.nameserver

  sshkeys = var.ssh_keys

  # Lifecycle settings
  lifecycle {
    ignore_changes = [
      network,
      disk,
    ]
  }
}
