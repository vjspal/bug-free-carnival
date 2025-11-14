# Home Lab Architecture

This document details the network architecture, resource allocation, security design, and technical decisions for the automated home lab.

## 📐 Network Architecture

### Network Topology

```
Internet
    │
    ├─ Router (192.168.1.1)
    │
    └─ Proxmox Host (192.168.1.200)
        │
        ├─ vmbr0 (Bridge - Management & Services)
        │   ├─ 192.168.1.0/24 - Management Network
        │   └─ Services: DNS, Reverse Proxy, Apps
        │
        ├─ vmbr1 (Bridge - Storage Network) [Future]
        │   └─ 192.168.10.0/24 - NAS, Backup
        │
        └─ vmbr2 (Bridge - IoT/Cameras) [Future]
            └─ 192.168.20.0/24 - Home Assistant, Frigate
```

### IP Allocation Plan

#### Management Network (192.168.1.0/24)
```
192.168.1.1       - Router/Gateway
192.168.1.200     - Proxmox Host (duality)
192.168.1.210-219 - Infrastructure VMs (DNS, Proxy, Git)
192.168.1.220-229 - Service VMs (Nextcloud, Media, etc.)
192.168.1.230-239 - Development VMs (Coder, Test VMs)
192.168.1.240-249 - LXC Containers
192.168.1.250-254 - Reserved
```

#### Specific Assignments (Phase 1 & 2)
| IP Address | Hostname | Type | Purpose |
|------------|----------|------|---------|
| 192.168.1.210 | dns.homelab.local | LXC | Pi-hole + Unbound |
| 192.168.1.211 | proxy.homelab.local | VM | Traefik Reverse Proxy |
| 192.168.1.212 | git.homelab.local | LXC | Gitea |
| 192.168.1.213 | automation.homelab.local | VM | Semaphore |
| 192.168.1.220 | nas.homelab.local | VM | OpenMediaVault / NFS |
| 192.168.1.221 | cloud.homelab.local | VM | Nextcloud |

### DNS Strategy

**Internal DNS (Phase 2):**
- **Pi-hole**: Primary DNS with ad-blocking
- **Unbound**: Recursive DNS resolver (upstream from Pi-hole)
- **Zone**: `.homelab.local` for all internal services

**DNS Flow:**
```
Client → Pi-hole (192.168.1.210)
         ├─ Local record? → Return IP
         ├─ Blocked? → Return NXDOMAIN
         └─ External? → Unbound → Root servers
```

**Static DNS Records** (configured in Pi-hole):
```
dns.homelab.local       → 192.168.1.210
proxy.homelab.local     → 192.168.1.211
git.homelab.local       → 192.168.1.212
automation.homelab.local → 192.168.1.213
*.apps.homelab.local    → 192.168.1.211 (wildcard to proxy)
```

### Reverse Proxy (Traefik)

**Purpose**:
- HTTPS termination with Let's Encrypt or self-signed CA
- Service routing based on hostname
- Automatic service discovery via Docker labels

**Configuration**:
- Entry points: HTTP (80) → HTTPS (443)
- Middleware: Authentication, rate limiting, headers
- Backends: All services behind proxy

**Example Routing**:
```
https://git.homelab.local     → Gitea (192.168.1.212:3000)
https://cloud.homelab.local   → Nextcloud (192.168.1.221:80)
https://semaphore.homelab.local → Semaphore (192.168.1.213:3000)
```

## 🖥️ Resource Allocation

### Total Available Resources
- **CPU**: 24 threads (2x Xeon 6-core with HT)
- **RAM**: 32 GB
- **Storage**: 4 TB HDD (local-zfs)

### Proxmox Host Reservation
- **CPU**: 4 threads reserved
- **RAM**: 8 GB reserved
- **Available for VMs**: 20 threads, 24 GB RAM

### VM/LXC Allocations

#### Phase 1: Core Automation
| Service | Type | vCPU | RAM | Disk | Notes |
|---------|------|------|-----|------|-------|
| Gitea | LXC | 1 | 1 GB | 20 GB | Lightweight Git |
| Semaphore | VM | 2 | 2 GB | 20 GB | Ansible UI |
| Test VM | VM | 1 | 1 GB | 10 GB | Validation only |
| **Subtotal** | | **4** | **4 GB** | **50 GB** | |

#### Phase 2: Essential Services
| Service | Type | vCPU | RAM | Disk | Notes |
|---------|------|------|-----|------|-------|
| Pi-hole + Unbound | LXC | 1 | 1 GB | 10 GB | DNS |
| Traefik | VM | 2 | 2 GB | 20 GB | Reverse proxy |
| NAS/Storage | VM | 2 | 4 GB | 500 GB | NFS/SMB shares |
| **Subtotal** | | **5** | **7 GB** | **530 GB** | |

#### Phase 3A: Media Stack (Optional)
| Service | Type | vCPU | RAM | Disk | Notes |
|---------|------|------|-----|------|-------|
| Media VM | VM | 4 | 8 GB | 100 GB | *arr + qBit + Gluetun + Jellyfin |
| **Subtotal** | | **4** | **8 GB** | **100 GB** | Requires storage from NAS |

#### Phase 3B: AI & Development (Optional)
| Service | Type | vCPU | RAM | Disk | Notes |
|---------|------|------|-----|------|-------|
| Coder | VM | 2 | 4 GB | 50 GB | Dev environments |
| AI/LLM | VM | 4 | 8 GB | 100 GB | Ollama + RAG, needs GPU passthrough |
| **Subtotal** | | **6** | **12 GB** | **150 GB** | |

#### Phase 3C: Home Automation (Optional)
| Service | Type | vCPU | RAM | Disk | Notes |
|---------|------|------|-----|------|-------|
| Home Assistant | VM | 2 | 4 GB | 32 GB | HAOS VM |
| Frigate NVR | VM | 4 | 6 GB | 50 GB | Needs Coral TPU |
| **Subtotal** | | **6** | **10 GB** | **82 GB** | |

### Storage Strategy

**Current**: 4 TB HDD (local-zfs)
- **System/Boot**: ~50 GB
- **VM Templates**: ~20 GB
- **Phase 1+2 VMs**: ~600 GB
- **Available**: ~3.3 TB

**Future NVMe Addition**:
- Hot-tier: Databases, frequently accessed data
- Cold-tier: Media, backups on HDD

**Backup Strategy**:
- Proxmox snapshots before changes
- Terraform state backed up to Git
- Critical data backed up to external drive (future)

## 🔒 Security Architecture

### Access Control

**Proxmox Access**:
- Web UI: `https://192.168.1.200:8006` (management network only)
- SSH: Key-based authentication only, root login disabled
- API: Token-based auth for Terraform/Packer

**VM/LXC Access**:
- SSH: Key-based authentication only
- No password authentication
- Fail2ban on public-facing services

**External Access**:
- Tailscale VPN for secure remote management
- No direct port forwarding to Proxmox (exception: reverse proxy 80/443 if needed)

### Network Segmentation (Future)

**VLAN Plan** (when ready to implement):
```
VLAN 1 (Default)    - Management (Proxmox, admin VMs)
VLAN 10             - Services (Web apps, databases)
VLAN 20             - IoT (Home Assistant, cameras)
VLAN 30             - Guest WiFi (isolated)
```

**Firewall Rules** (to be implemented):
- IoT cannot reach management VLAN
- Guests cannot reach any internal networks
- Services can reach NAS only

### Secrets Management

**Ansible Vault**:
- All API keys, passwords, tokens encrypted
- Vault password stored in password manager (NOT in repo)
- Each environment (dev/prod) has separate vault

**Terraform Variables**:
- `terraform.tfvars` excluded from Git
- `terraform.tfvars.example` provided as template
- Sensitive variables marked with `sensitive = true`

**SSL Certificates**:
- Let's Encrypt for external domains
- Self-signed CA for internal *.homelab.local (future)
- Certificates managed by Traefik

### Security Best Practices

- [x] No plaintext secrets in Git
- [ ] Automated security updates (Ansible role)
- [ ] Fail2ban on all public services
- [ ] Regular Proxmox backups
- [ ] Firewall rules between VLANs
- [ ] Intrusion detection (future - Wazuh/Suricata)
- [ ] Regular security audits

## 🛠️ Technical Decisions

### Why These Choices?

**Proxmox VE**:
- ✅ Free and open-source
- ✅ Mature virtualization platform
- ✅ Supports VMs (KVM) and LXC containers
- ✅ Built-in clustering (future expansion)
- ❌ Requires local access for installation

**Packer for Templates**:
- ✅ Standardized, repeatable VM images
- ✅ Cloud-init enabled for easy provisioning
- ✅ Version-controlled image definitions
- ❌ Initial build time (~30 minutes)

**Terraform for Infrastructure**:
- ✅ Declarative infrastructure definition
- ✅ State management and drift detection
- ✅ Plan before apply (safety)
- ❌ Learning curve, state file management

**Ansible for Configuration**:
- ✅ Idempotent, easy to read (YAML)
- ✅ Agentless (SSH-based)
- ✅ Massive community ecosystem
- ❌ Can be slow for large inventories

**Traefik vs Nginx Proxy Manager**:
- **Traefik chosen** for:
  - Configuration as code (Docker labels, file config)
  - Automatic service discovery
  - Built-in Let's Encrypt
  - Better IaC alignment
- **NPM alternative**:
  - Easier initial setup
  - Web UI for management
  - Less IaC-friendly (database config)

**LXC vs Docker vs VM**:
- **LXC**: Lightweight system services (DNS, Git)
- **Docker**: Application services (media stack, n8n)
- **VM**: Full OS needed (Windows, HAOS) or isolation required

## 📊 Monitoring & Observability (Future)

**Phase 4 considerations**:
- **Metrics**: Prometheus + Grafana
- **Logs**: Loki or ELK stack
- **Uptime**: Uptime Kuma
- **Alerts**: Discord/Email notifications

## 🔄 Disaster Recovery

### Backup Strategy
1. **Proxmox snapshots** before major changes
2. **Git repository** backed up to GitHub/external Git
3. **Terraform state** committed to Git (with encryption for sensitive modules)
4. **VM data** backed up to external drive (weekly)
5. **Documentation** up-to-date (this repo)

### Recovery Procedures
1. **Complete rebuild**: Run Packer → Terraform → Ansible
2. **Single service failure**: Ansible playbook re-run
3. **VM corruption**: Restore from snapshot or rebuild from code
4. **Data loss**: Restore from backup drive

### RTO/RPO Goals
- **Recovery Time Objective (RTO)**: 4 hours (complete rebuild)
- **Recovery Point Objective (RPO)**: 24 hours (daily backups)

## 📈 Future Enhancements

### Hardware Upgrades
- [ ] Add NVMe SSD for performance tier
- [ ] Upgrade GPU to 3070 for AI workloads
- [ ] Add Coral TPU for Frigate
- [ ] Expand RAM to 64 GB

### Infrastructure Improvements
- [ ] Implement VLAN segmentation
- [ ] Set up internal PKI for certificates
- [ ] Add redundancy (second Proxmox node)
- [ ] Implement automated testing (Molecule for Ansible)

### Services to Add
- [ ] Monitoring stack (Prometheus, Grafana)
- [ ] Centralized logging (Loki)
- [ ] CI/CD pipeline (Gitea Actions / Jenkins)
- [ ] Backup solution (Proxmox Backup Server)

---

**Document Version**: 1.0
**Last Updated**: 2025-11-14
**Status**: Phase 0 - Initial architecture defined
