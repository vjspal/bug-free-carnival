# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

**Automated Home Lab** - A fully automated home lab infrastructure built with Infrastructure as Code (IaC) principles using Proxmox VE, Packer, Terraform, and Ansible.

**Vision**: Build a powerful, resilient, and fully automated home lab environment that serves as a platform for hosting business-oriented, open-source services. Everything is repeatable, version-controlled, and can be destroyed/recreated at will.

**Current Status**: Phase 0 Complete ✅ | Phase 1 Preparation Ready ✅

## Core Architecture

### Three-Layer Infrastructure Stack

1. **Packer** (`packer/`) - VM template creation
   - Builds Ubuntu 22.04 cloud-init templates for Proxmox
   - Uses autoinstall with cloud-init for unattended installation
   - Provisions base images with qemu-guest-agent and cloud-init pre-installed
   - Status: ✅ Template validated and ready to build

2. **Terraform** (`terraform/`) - VM provisioning
   - Uses Packer-built templates to provision VMs
   - Reusable modules for VM creation (`modules/vm-from-template/`)
   - Structured with `vms/` subdirectory for VM definitions
   - Status: ✅ Initialized and configured (terraform.tfvars created)

3. **Ansible** (`ansible/`) - Configuration management
   - Configures provisioned VMs with roles
   - Base roles: `common` (system setup), `docker` (container runtime)
   - Ansible Vault for secrets management
   - Status: ✅ Installed, vault configured, roles ready

## Installation Status

| Tool | Version | Status | Location |
|------|---------|--------|----------|
| **Packer** | (pre-installed) | ✅ Ready | `/usr/bin/packer` |
| **Terraform** | 1.13.5 | ✅ Installed | `/usr/bin/terraform` |
| **Ansible** | 12.2.0 (core 2.19.4) | ✅ Installed | `/usr/local/bin/ansible` |
| **Proxmox VE** | 9.0.11 | ✅ Running | Local host |
| **Python** | 3.13.5 | ✅ Available | `/usr/bin/python3` |

## Documentation

The repository includes comprehensive documentation:

- **README.md** - Project overview, quick start, implementation phases
- **ARCHITECTURE.md** - Network design, IP allocation, resource planning, security
- **SERVICE_CATALOG.md** - Complete service inventory and deployment tracking
- **terraform/README.md** - Terraform usage guide
- **ansible/README.md** - Ansible usage guide

## Common Commands

### Packer

Validate template:
```bash
cd packer
packer validate -var "pm_password=dummy" ubuntu-22.04-lts.pkr.hcl
```

Build Ubuntu 22.04 template:
```bash
cd packer
packer build -var "pm_password=YOUR_PROXMOX_PASSWORD" ubuntu-22.04-lts.pkr.hcl
```

Format Packer HCL files:
```bash
packer fmt packer/
```

### Terraform

Initialize (already done):
```bash
cd terraform
terraform init
```

Validate configuration:
```bash
cd terraform
terraform validate
```

Plan changes:
```bash
cd terraform
terraform plan
```

Apply changes:
```bash
cd terraform
terraform apply
```

### Ansible

Test connectivity:
```bash
cd ansible
ansible all -m ping
```

Run main playbook:
```bash
cd ansible
ansible-playbook playbooks/site.yml
```

Run with check mode (dry run):
```bash
cd ansible
ansible-playbook playbooks/site.yml --check
```

Edit vault:
```bash
cd ansible
ansible-vault edit group_vars/vault.yml
```

View vault:
```bash
cd ansible
ansible-vault view group_vars/vault.yml
```

## Environment Configuration

### Proxmox Connection

The environment is configured for Proxmox node "duality":
- **API URL**: https://192.168.1.200:8006/api2/json
- **Node name**: duality
- **ISO storage**: local
- **Disk storage**: local-zfs (ZFS pool)
- **Network bridge**: vmbr0

### Network Architecture

**Management Network**: 192.168.1.0/24
- Gateway: 192.168.1.1
- Proxmox Host: 192.168.1.200
- Infrastructure VMs: 192.168.1.210-219
- Service VMs: 192.168.1.220-229
- Development VMs: 192.168.1.230-239
- LXC Containers: 192.168.1.240-249

See ARCHITECTURE.md for complete IP allocation plan.

### Configuration Files

**Terraform** (`terraform/terraform.tfvars`):
- ✅ Created with SSH key auto-populated
- ⚠️ Needs Proxmox API token secret (currently: "REPLACE_WITH_YOUR_TOKEN_SECRET")
- To create API token: `pveum user token add root@pam terraform -privsep 0`

**Ansible Vault** (`ansible/vault_password.txt`):
- ✅ Vault password generated and stored securely (chmod 600)
- ✅ Encrypted vault file created (`group_vars/vault.yml`)
- ⚠️ Contains placeholder secrets - update with: `ansible-vault edit group_vars/vault.yml`

**SSH Keys**:
- ✅ SSH public key: `/root/.ssh/id_rsa.pub` (already configured in terraform.tfvars)

## Implementation Phases

### Phase 0: Foundation ✅ COMPLETE
- [x] Core documentation (README, ARCHITECTURE, SERVICE_CATALOG)
- [x] Comprehensive .gitignore for secrets protection
- [x] Terraform structure with reusable modules
- [x] Ansible structure with base roles (common, docker)
- [x] Packer template fixed and validated
- [x] All changes committed to Git

### Phase 1: Core Automation (MVP) - NEXT
**Goal**: Prove IaC/CaC workflow end-to-end

**Services to deploy**:
1. Gitea (self-hosted Git) - LXC container
2. Semaphore (Ansible/Terraform UI) - Docker VM
3. Test VM (workflow validation) - Simple VM

**Prerequisite Steps**:
1. ⚠️ Create Proxmox API token
2. ⚠️ Update `terraform/terraform.tfvars` with API token secret
3. ⚠️ Build Packer template (requires Proxmox password)
4. ⚠️ Update Ansible vault with service passwords

**Success Criteria**:
- [ ] Packer template built successfully
- [ ] Terraform provisions VMs from template
- [ ] Ansible configures VMs via playbooks
- [ ] Full destroy/recreate cycle works

### Phase 2: Essential Infrastructure - PLANNED
1. Pi-hole + Unbound (DNS)
2. Traefik (reverse proxy + HTTPS)
3. NAS/Storage (shared storage)

### Phase 3: Optional Service Tracks - PLANNED
Choose one track based on priority:
- **Track A**: Media Stack (Jellyfin, *arr suite, qBittorrent)
- **Track B**: AI & Development (Coder, Ollama, RAG pipeline)
- **Track C**: Home Automation (Home Assistant, Frigate NVR)

## Quick Start Workflow

### 1. Complete Phase 1 Prerequisites

Create Proxmox API token:
```bash
# SSH to Proxmox host (already here)
pveum user token add root@pam terraform -privsep 0
# Copy the token secret that is displayed
```

Update Terraform configuration:
```bash
cd terraform
nano terraform.tfvars
# Replace "REPLACE_WITH_YOUR_TOKEN_SECRET" with actual token
```

### 2. Build Packer Template

```bash
cd packer
read -s PM_PASSWORD
packer build -var "pm_password=$PM_PASSWORD" ubuntu-22.04-lts.pkr.hcl
```

Wait ~30 minutes for build to complete. Result: Template named `ubuntu-2204-cloudinit-template` in Proxmox.

### 3. Deploy Test VM

```bash
cd terraform/vms
cp vm-test.tf.example vm-test.tf
cd ..
terraform plan
terraform apply
```

### 4. Configure with Ansible

```bash
cd ansible
# Wait 2-3 minutes for cloud-init to complete on new VM
ansible all -m ping
ansible-playbook playbooks/site.yml
```

## Security & Secrets

**Protected Files** (in .gitignore):
- `terraform/terraform.tfvars` - Contains API tokens and SSH keys
- `ansible/vault_password.txt` - Vault decryption password
- `ansible/group_vars/vault.yml` - Encrypted secrets (safe to commit)
- `*.tfstate` - Terraform state files
- `*.retry` - Ansible retry files

**Vault Management**:
```bash
# Edit vault
ansible-vault edit ansible/group_vars/vault.yml

# View vault
ansible-vault view ansible/group_vars/vault.yml

# Change vault password
ansible-vault rekey ansible/group_vars/vault.yml
```

## Common Issues & Solutions

### "Template not found" (Terraform)
- Ensure Packer template is built first
- Verify template name in Proxmox matches `terraform.tfvars`

### "Permission denied" (Terraform)
- Check API token has correct permissions
- Required roles: `PVEVMAdmin`, `PVEDatastoreUser`

### "Host unreachable" (Ansible)
- VM may still be running cloud-init (wait 2-3 min)
- Verify IP address in `inventory/hosts.yml`
- Test SSH manually: `ssh admin@<vm-ip>`

### "Vault password not found" (Ansible)
- Ensure `ansible/vault_password.txt` exists
- Or use `--ask-vault-pass` flag

## Repository Structure

```
.
├── README.md                    # Main documentation
├── ARCHITECTURE.md              # Network & security design
├── SERVICE_CATALOG.md           # Service inventory
├── .gitignore                   # Secrets protection
├── packer/
│   ├── ubuntu-22.04-lts.pkr.hcl # VM template builder
│   └── http/                    # Cloud-init configs
├── terraform/
│   ├── main.tf                  # Provider config
│   ├── variables.tf             # Variable definitions
│   ├── terraform.tfvars         # ✅ Created (needs API token)
│   ├── modules/
│   │   └── vm-from-template/    # Reusable VM module
│   └── vms/                     # VM definitions
└── ansible/
    ├── ansible.cfg              # Ansible config
    ├── vault_password.txt       # ✅ Created (chmod 600)
    ├── inventory/
    │   └── hosts.yml            # Inventory file
    ├── group_vars/
    │   ├── all.yml              # Global variables
    │   └── vault.yml            # ✅ Encrypted secrets
    ├── playbooks/
    │   └── site.yml             # Main playbook
    └── roles/
        ├── common/              # Base system setup
        └── docker/              # Docker installation
```

## Next Actions

To proceed with Phase 1:

1. **Create Proxmox API Token** (5 minutes)
   ```bash
   pveum user token add root@pam terraform -privsep 0
   ```

2. **Update terraform.tfvars** (2 minutes)
   - Replace `REPLACE_WITH_YOUR_TOKEN_SECRET` with actual token

3. **Build Packer Template** (30 minutes)
   ```bash
   cd packer
   packer build -var "pm_password=YOUR_PROXMOX_PASSWORD" ubuntu-22.04-lts.pkr.hcl
   ```

4. **Deploy Test VM** (5 minutes)
   ```bash
   cd terraform/vms
   cp vm-test.tf.example vm-test.tf
   cd .. && terraform apply
   ```

5. **Configure with Ansible** (5 minutes)
   ```bash
   cd ansible
   ansible-playbook playbooks/site.yml
   ```

After these steps, you'll have a validated end-to-end workflow ready for Phase 1 service deployments.

## GitHub Integration

This repository includes GitHub Actions workflows for Claude Code integration:
- `.github/workflows/claude.yml` - Claude PR assistant (@claude in issues/PRs)
- `.github/workflows/claude-code-review.yml` - Automated code review

---

**Last Updated**: 2025-11-14
**Environment**: Proxmox VE 9.0.11 on Debian 13 (Trixie)
**Branch**: main
