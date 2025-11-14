packer {
required_version = ">= 1.11.0"
required_plugins {
proxmox = { source = "github.com/hashicorp/proxmox", version = ">= 1.2.0" }
}
}


variable "pm_password" { type = string, sensitive = true }


locals {
# Assumptions (explicit): node=duality, ISO store=local, disk store=local-zfs, bridge=vmbr0
pm_api_url = "https://192.168.1.200:8006/api2/json"
pm_node = "duality"
iso_store = "local"
disk_store = "local-zfs"
bridge = "vmbr0"


vm_name = "tmp-ubuntu-2204-ci"
iso_url = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
# Keep the sha256: prefix
iso_checksum = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
}


source "proxmox-iso" "ubuntu" {
  proxmox_url              = local.pm_api_url
  username                 = "root@pam"
  password                 = var.pm_password
  insecure_skip_tls_verify = true

  node    = local.pm_node
  vm_name = local.vm_name

  # VM Resources
  cores   = 2
  memory  = 2048
  sockets = 1

  # ISO Configuration
  iso_storage_pool = local.iso_store
  iso_url          = local.iso_url
  iso_checksum     = local.iso_checksum
  unmount_iso      = true

  # Disk Configuration
  scsi_controller = "virtio-scsi-pci"

  disk {
    type              = "scsi"
    disk_size         = "20G"
    storage_pool      = local.disk_store
    storage_pool_type = "zfspool"
  }

  # Network Configuration
  network_adapters {
    model  = "virtio"
    bridge = local.bridge
  }

  # HTTP server for cloud-init
  http_directory = "packer/http"

  # Boot commands to trigger autoinstall
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down>",
    "<end> autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---",
    "<f10>"
  ]

  # SSH Configuration
  ssh_username = "packer"
  ssh_password = "packer"
  ssh_timeout  = "30m"
}


build {
  name    = "ubuntu-2204-cloudinit-template"
  sources = ["source.proxmox-iso.ubuntu"]

  # Update system and install essentials
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y qemu-guest-agent cloud-init",
      "sudo systemctl enable qemu-guest-agent",
      "sudo cloud-init clean"
    ]
  }

  # Clean up before template creation
  provisioner "shell" {
    inline = [
      "sudo apt-get autoremove -y",
      "sudo apt-get clean",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/tmp/*",
      "history -c"
    ]
  }
}