# Automated Home Lab

A fully automated home lab infrastructure built with Infrastructure as Code (IaC) principles using Proxmox, Packer, Terraform, and Ansible.

## 🎯 Vision

Build a powerful, resilient, and fully automated home lab environment that serves as a platform for hosting business-oriented, open-source services. Everything is repeatable, version-controlled, and can be destroyed/recreated at will.

## 📋 Core Principles

- **Automation First**: All infrastructure managed through code, no manual "click-ops"
- **Repeatability**: Entire lab can be destroyed and recreated from code
- **Living Documentation**: Code is the single source of truth
- **Open Source Focus**: Prioritize FOSS for flexibility and learning
- **Utility & Purpose**: Host services with tangible business value

## 🏗️ Architecture

### Hardware
- **CPU**: 2x Intel Xeon (6 cores each, 12 cores / 24 threads total)
- **RAM**: 32 GB DDR3/4 ECC
- **Storage**: 4 TB HDD (boot), NVMe planned for future upgrade
- **GPU**: NVIDIA Quadro (placeholder for future 3070 for AI/ML)
- **Network**: 2x 1GbE NICs, Tailscale for secure remote access

### Technology Stack
- **Virtualization**: Proxmox VE 8.x
- **Image Building**: Packer (cloud-init enabled VM templates)
- **Infrastructure as Code**: Terraform (VM/LXC provisioning)
- **Configuration Management**: Ansible (OS & application configuration)
- **Reverse Proxy**: Traefik (HTTPS termination, service routing)
- **Internal DNS**: Pi-hole + Unbound (network-wide DNS & ad-blocking)
- **Automation UI**: Semaphore (visual Ansible/Terraform orchestration)

## 📁 Repository Structure

```
.
├── README.md                    # This file
├── ARCHITECTURE.md              # Network design, IP allocation, security
├── SERVICE_CATALOG.md           # All services with deployment status
├── packer/
│   ├── ubuntu-22.04-lts.pkr.hcl # Base VM template
│   └── http/                    # Cloud-init configs
├── terraform/
│   ├── main.tf                  # Provider configuration
│   ├── variables.tf             # Variable definitions
│   ├── terraform.tfvars.example # Template for secrets
│   ├── network.tf               # Network resources
│   └── modules/
│       ├── lxc-container/       # Reusable LXC module
│       └── vm-from-template/    # Reusable VM module
├── ansible/
│   ├── ansible.cfg              # Ansible configuration
│   ├── inventory/
│   │   └── hosts.yml            # Inventory file
│   ├── group_vars/
│   │   ├── all.yml              # Global variables
│   │   └── vault.yml            # Encrypted secrets
│   ├── roles/
│   │   ├── common/              # Base system setup
│   │   ├── docker/              # Docker installation
│   │   ├── networking/          # DNS, reverse proxy
│   │   └── ...                  # Service-specific roles
│   └── playbooks/
│       └── site.yml             # Main playbook
└── docs/
    ├── GETTING_STARTED.md       # Setup guide
    ├── PACKER_GUIDE.md          # Packer usage
    ├── TERRAFORM_GUIDE.md       # Terraform usage
    └── ANSIBLE_GUIDE.md         # Ansible usage
```

## 🚀 Implementation Phases

### Phase 0: Foundation (CURRENT)
**Status**: 🟡 In Progress

- [x] Create .gitignore
- [x] Create README.md
- [ ] Create ARCHITECTURE.md
- [ ] Document network design
- [ ] Test Packer template build
- [ ] Create Terraform structure
- [ ] Create Ansible structure
- [ ] Set up Ansible Vault

### Phase 1: Core Automation Pipeline (MVP)
**Status**: ⚪ Not Started

**Goal**: Prove IaC/CaC workflow end-to-end

**Services**:
- [ ] Gitea (self-hosted Git repository)
- [ ] Semaphore (Ansible/Terraform UI)
- [ ] Test VM (simple nginx to validate workflow)

**Success Criteria**:
- Code stored in self-hosted Gitea
- Terraform provisions VMs from Packer template
- Ansible configures VMs via Semaphore
- Full destroy/recreate cycle works

### Phase 2: Essential Services
**Status**: ⚪ Not Started

**Goal**: Deploy foundational infrastructure services

**Services**:
1. DNS & Network (Pi-hole + Unbound)
2. Reverse Proxy (Traefik)
3. NAS/Storage (OMV or NFS share)

**Success Criteria**:
- Internal DNS resolution (*.homelab.local)
- HTTPS with valid certificates
- Shared storage accessible by all VMs

### Phase 3: Optional Service Tracks
**Status**: ⚪ Not Started

Choose ONE track based on priority:

#### Track A: Media Stack
- Gluetun (VPN)
- qBittorrent, Sonarr, Radarr, Prowlarr
- Jellyfin media server

#### Track B: AI & Development
- Coder (remote development)
- Ollama (local LLM)
- RAG pipeline (Obsidian integration)

#### Track C: Home Automation
- Home Assistant
- Frigate NVR
- Camera integration

## 🔧 Prerequisites

### Software Requirements
- Proxmox VE 8.x installed on host
- Packer >= 1.11.0
- Terraform >= 1.5.0
- Ansible >= 2.15

### Proxmox Setup
1. Create API token for automation:
   - User: `root@pam`
   - Permissions: `PVEVMAdmin`, `PVEDatastoreUser`
2. Note your node name (default: `duality`)
3. Verify ISO storage pool (default: `local`)
4. Verify disk storage pool (default: `local-zfs`)

### Network Setup
- Static IP for Proxmox host: `192.168.1.200`
- Available DHCP range or static IPs for VMs
- Port forwarding configured (optional, for external access)

## 📚 Quick Start

### 1. Build VM Template with Packer

```bash
cd packer/
# Create a file with your Proxmox password
echo "your-password" > pm_password.txt

# Validate the template
packer validate -var "pm_password=$(cat pm_password.txt)" ubuntu-22.04-lts.pkr.hcl

# Build the template
packer build -var "pm_password=$(cat pm_password.txt)" ubuntu-22.04-lts.pkr.hcl

# Clean up
rm pm_password.txt
```

### 2. Provision Infrastructure with Terraform

```bash
cd terraform/
# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply
```

### 3. Configure Services with Ansible

```bash
cd ansible/
# Create vault password file
echo "your-vault-password" > vault_password.txt
chmod 600 vault_password.txt

# Create encrypted vault
ansible-vault create group_vars/vault.yml

# Run playbook
ansible-playbook playbooks/site.yml
```

## 🔒 Security Considerations

- **Secrets Management**: All sensitive data in Ansible Vault
- **Network Segmentation**: VLANs for management, services, IoT (future)
- **Access Control**: Proxmox RBAC, SSH key-based auth only
- **Backups**: Regular backups of Terraform state and VM snapshots
- **Updates**: Automated security updates via Ansible

## 📖 Documentation

- [Architecture Details](ARCHITECTURE.md) - Network design, IP allocation
- [Service Catalog](SERVICE_CATALOG.md) - All services and their status
- [Getting Started](docs/GETTING_STARTED.md) - Detailed setup guide
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

## 🤝 Contributing

This is a personal learning project, but suggestions are welcome via issues.

## 📝 License

This project is licensed under the terms specified in the LICENSE file.

## 🙏 Acknowledgments

Key resources and inspiration:
- [khuedoan/homelab](https://github.com/khuedoan/homelab) - GitOps home lab reference
- [ccbikai/awesome-homelab](https://github.com/ccbikai/awesome-homelab) - Service catalog
- [ChristianLempa/boilerplates](https://github.com/ChristianLempa/boilerplates) - IaC templates
- Proxmox, Terraform, Ansible communities

---

**Current Status**: Phase 0 - Foundation setup in progress

Last Updated: 2025-11-14
