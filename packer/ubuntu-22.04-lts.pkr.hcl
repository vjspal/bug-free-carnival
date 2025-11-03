packer {
  required_version = ">= 1.11.0"
  required_plugins {
    proxmox = { source = "github.com/hashicorp/proxmox", version = ">= 1.2.0" }
  }
}

locals {
  # I’m assuming these based on your host. Change if needed.
  pm_api_url  = "https://127.0.0.1:8006/api2/json"
  pm_node     = "duality"
  iso_store   = "local"       # ISO-capable (dir)
  disk_store  = "local-zfs"   # template disk target (zfspool)
  bridge      = "vmbr0"

  vm_name     = "tmp-ubuntu-2204-ci"
  iso_url     = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum = "sha256:PUT_REAL_SHA256_HERE"  # <-- fill in step 2
}

source "proxmox-iso" "ubuntu" {
  proxmox_url      = local.pm_api_url
  username         = "root@pam"                # assuming root auth
  password         = env("PM_PASS")            # export PM_PASS before build
  insecure_skip_tls_verify = true

  node             = local.pm_node
  vm_name          = local.vm_name

  iso_storage_pool = local.iso_store
  iso_url          = local.iso_url
  iso_checksum     = local.iso_checksum

  scsi_controller  = "virtio-scsi-pci"
  disks = [{
    type              = "scsi"
    disk_size         = "20G"
    storage_pool      = local.disk_store
    storage_pool_type = "zfspool"
  }]

  cores  = 2
  memory = 2048

  network_adapters = [{ model = "virtio", bridge = local.bridge }]

  http_directory = "packer/http"

  boot_command = [
    "<esc><wait>", "e<wait>",
    "<down><down><down>", "<end> autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---",
    "<f10>"
  ]

  ssh_username     = "packer"
  ssh_password     = "packer"
  ssh_timeout      = "30m"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  name    = "ubuntu-2204-cloudinit-template"
  sources = ["source.proxmox-iso.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y qemu-guest-agent cloud-init",
      "sudo useradd -m -s /bin/bash vj || true",
      "echo 'vj ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/90-vj >/dev/null",
      "sudo mkdir -p /home/vj/.ssh && sudo chmod 700 /home/vj/.ssh",
      "sudo systemctl enable --now qemu-guest-agent",
    ]
  }

  post-processor "shell-local" {
    inline = [
      "VMID=$(qm list | awk '$2==\"'${local.vm_name}'\" {print $1}')",
      "[ -n \"$VMID\" ] || { echo 'Cannot find built VM ID'; exit 1; }",
      "qm stop $VMID || true",
      "qm template $VMID",
      "qm set $VMID --name ubuntu-2204-cloudinit-template",
      "echo \"Templatized VMID=$VMID as ubuntu-2204-cloudinit-template\""
    ]
  }
}
