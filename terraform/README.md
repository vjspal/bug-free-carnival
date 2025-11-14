# Terraform Configuration

This directory contains Terraform configuration for provisioning VMs and LXC containers on Proxmox.

## Prerequisites

1. **Terraform installed** (>= 1.5.0)
2. **Proxmox API token** created with appropriate permissions
3. **Packer template** built and available (`ubuntu-2204-cloudinit-template`)

## Initial Setup

### 1. Create API Token in Proxmox

```bash
# SSH into Proxmox host
ssh root@192.168.1.200

# Create API token
pveum user token add root@pam terraform -privsep 0

# Note the token ID and secret - you'll need these for terraform.tfvars
```

### 2. Configure Variables

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

Required values:
- `proxmox_api_token_secret`: From step 1
- `ssh_public_key`: Your SSH public key

### 3. Initialize Terraform

```bash
terraform init
```

## Usage

### Validate Configuration

```bash
terraform validate
```

### Plan Changes

```bash
terraform plan
```

### Apply Changes

```bash
terraform apply
```

### Destroy Resources

```bash
terraform destroy
```

## Directory Structure

```
terraform/
├── main.tf                      # Provider configuration
├── variables.tf                 # Variable definitions
├── terraform.tfvars.example     # Example values
├── terraform.tfvars             # Actual values (gitignored)
├── outputs.tf                   # Output definitions
├── modules/
│   ├── vm-from-template/        # Reusable VM module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── lxc-container/           # Reusable LXC module (TODO)
└── vms/
    ├── vm-test.tf.example       # Example test VM
    ├── vm-gitea.tf              # Gitea VM (Phase 1)
    ├── vm-semaphore.tf          # Semaphore VM (Phase 1)
    └── ...                      # Additional VMs per phase
```

## Creating a New VM

1. Create a new file in `vms/` directory (e.g., `vm-myservice.tf`)
2. Use the `vm-from-template` module:

```hcl
module "myservice" {
  source = "../modules/vm-from-template"

  vm_name       = "myservice"
  target_node   = var.proxmox_node
  template_name = var.template_name
  description   = "My service VM"

  cores     = 2
  memory    = 2048
  disk_size = "20G"

  storage        = var.proxmox_storage
  network_bridge = var.network_bridge
  ip_address     = "192.168.1.XXX"  # Choose from architecture plan
  gateway        = var.network_gateway
  nameserver     = var.dns_server
  ssh_keys       = var.ssh_public_key
}

output "myservice_ip" {
  value = module.myservice.ip_address
}
```

3. Run `terraform plan` to preview
4. Run `terraform apply` to create

## Common Issues

### "Template not found"
- Ensure Packer template is built first
- Verify template name matches `var.template_name`

### "Permission denied"
- Check API token permissions in Proxmox
- Ensure token has `PVEVMAdmin` and `PVEDatastoreUser` roles

### "Connection refused"
- Verify `proxmox_api_url` is correct
- Check Proxmox host is accessible
- Verify port 8006 is open

### State File Issues
- Backup `.tfstate` files regularly
- Consider remote state (Terraform Cloud, S3, etc.) for production

## Best Practices

1. **Always run `terraform plan` before `apply`**
2. **Commit state files to Git** (for solo projects) or use remote state
3. **Use modules for reusability**
4. **Document VM IP addresses** in ARCHITECTURE.md
5. **Tag resources** with environment, owner, purpose

## Integration with Ansible

After Terraform creates a VM:

1. **Wait for cloud-init to complete** (~2-3 minutes)
2. **Verify SSH access**: `ssh admin@<vm-ip>`
3. **Add to Ansible inventory**: Update `ansible/inventory/hosts.yml`
4. **Run Ansible playbook** to configure the VM

## Next Steps

1. Build Packer template (if not done)
2. Create and configure `terraform.tfvars`
3. Deploy test VM to validate workflow
4. Proceed to Phase 1 VMs (Gitea, Semaphore)

---

For more details, see the main [README.md](../README.md) and [ARCHITECTURE.md](../ARCHITECTURE.md).
