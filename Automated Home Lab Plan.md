---
Type: "conversation"
created: 2025-10-30
---

```json
[
  {
    \\"role\\": \\"human\

Of course. Based on the detailed "Automated Home Lab Orchestration Plan" you provided, I will create a comprehensive implementation blueprint using the standard prp\_document\_template.md format.

This blueprint will structure your plan into an actionable sequence of tasks, complete with context, code patterns, and validation steps, making it ready for execution by a development agent or for you to follow manually.

Here is the generated blueprint:

---

## Discovery Summary

### Initial Task Analysis

The user has provided a comprehensive and well-researched Product Requirement Document (PRD) detailing the plan to build a fully automated home lab. The document outlines objectives, architecture, tooling, and a phased implementation plan. The goal is to translate this existing, detailed plan into the structured PRP format for guided execution.

### User Clarifications Received

No clarifications were needed. The provided PRD is exceptionally detailed and serves as the single source of truth for this blueprint.

### Missing Requirements Identified

No missing requirements were identified. The plan covers everything from infrastructure provisioning and configuration management to specific service deployments, networking, security, and AI integration.

## Goal

To build a stable, reproducible, and automated home lab environment that can deploy and manage a suite of self-hosted services on demand. The final system will serve as a platform for learning, experimentation, and as a portfolio piece demonstrating modern DevOps and infrastructure-as-code (IaC) practices.

## Why

- **Self-Reliance:** Replace third-party cloud and streaming services (Google Drive, Netflix, etc.) with self-hosted alternatives to increase privacy, control, and resilience against outages.
- **Skill Development:** Gain hands-on experience with enterprise-grade automation tools and practices, including Proxmox, Terraform, Packer, Ansible, Docker, and local AI/LLM integration.
- **Portfolio Building:** Create a demonstrable project that showcases valuable skills for small businesses and enterprise environments, such as automated service deployment, secure remote access, and AI-driven insights.
- **Efficiency:** Eliminate manual, repetitive server setup by defining the entire infrastructure and service configuration in version-controlled code.

## What

### Success Criteria

## All Needed Context

### Research Phase Summary

The provided PRD is the result of a thorough research phase.

- **Codebase patterns found**: This is a greenfield project. The PRD specifies using established community best practices and existing Ansible roles/Docker Compose files as patterns.
- **External research needed**: No. The PRD has already identified the necessary tools and best practices. The implementation will require referencing the official documentation for the chosen tools.
- **Knowledge gaps identified**: None. The plan is comprehensive.

### Documentation & References (list all context needed to implement the feature)

Yaml

```
# MUST READ - Include these in your context window
- doc: The user-provided PRD "Automated Home Lab Orchestration Plan"
  why: The single source of truth for all objectives and design decisions.

- url: https://pve.proxmox.com/pve-docs/
  why: Official Proxmox VE documentation for API, networking, and storage configuration.

- url: https://developer.hashicorp.com/packer/docs
  why: Official Packer documentation for building the base VM template.

- url: https://registry.terraform.io/providers/telmate/proxmox/latest/docs
  why: Documentation for the Terraform Proxmox provider for VM provisioning.

- url: https://docs.ansible.com/ansible/latest/index.html
  why: Official Ansible documentation for writing playbooks and roles.

- url: https://traefik.io/traefik/
  why: Documentation for Traefik reverse proxy if chosen over Nginx Proxy Manager.

- url: https://docs.pi-hole.net/
  why: Documentation for setting up the internal DNS and ad-blocking service.

- url: https://docs.home-assistant.io/
  why: Documentation for Home Assistant setup and integrations.

- url: https://docs.frigate.video/
  why: Documentation for Frigate NVR configuration and AI model tuning.

- url: https://github.com/ollama/ollama
  why: Documentation for deploying the local LLM service.
```

### Current Codebase tree (run tree in the root of the project) to get an overview of the codebase

Bash

```
# This is a new project, the codebase is currently empty.
```

### Desired Codebase tree with files to be added and responsibility of file

Bash

```
.
├── ansible/
│   ├── inventory/
│   │   └── hosts.yml           # Ansible inventory file
│   ├── group_vars/
│   │   └── all.yml             # Global Ansible variables
│   ├── roles/
│   │   ├── common/             # Base role for all servers (updates, users, etc.)
│   │   ├── docker/             # Role to install Docker and Docker Compose
│   │   ├── nextcloud/          # Role for Nextcloud deployment
│   │   ├── media_suite/        # Role for the *arr stack, downloaders, and VPN
│   │   ├── jellyfin/           # Role for Jellyfin media server
│   │   ├── home_assistant/     # Role for Home Assistant
│   │   ├── frigate/            # Role for Frigate NVR
│   │   ├── networking/         # Role for Pi-hole, reverse proxy, etc.
│   │   └── llm_stack/          # Role for Ollama and RAG pipeline setup
│   └── site.yml                # Main Ansible playbook to provision all services
├── packer/
│   └── ubuntu-22.04-lts.pkr.hcl # Packer template for the base Ubuntu VM image
├── terraform/
│   ├── main.tf                 # Main Terraform file defining the provider
│   ├── variables.tf            # Terraform variable definitions
│   ├── terraform.tfvars        # Secret/user-specific variable values (in .gitignore)
│   ├── network.tf              # Network resource definitions
│   └── vms/
│       ├── vm-media.tf         # Terraform definition for the media VM
│       ├── vm-nextcloud.tf     # Terraform definition for the Nextcloud VM
│       └── ...                 # One file per VM/LXC
└── README.md                   # Project overview and setup instructions
```

### Known Gotchas of our codebase & Library Quirks

Code

```
# Proxmox: API tokens need correct permissions for Terraform/Packer to work.
# Packer: Building from an ISO requires an unattended install configuration (e.g., autoinstall for Ubuntu).
# Ansible: Sensitive data (API keys, passwords) must be stored in Ansible Vault, not plaintext.
# Networking: The download client container (qBittorrent) MUST be networked through the VPN container (Gluetun) to prevent IP leaks. A kill-switch is mandatory.
# Frigate: AI object detection is CPU/GPU intensive. A Coral TPU is highly recommended to offload the CPU. Resource allocation for this VM is critical.
# Local LLM: Models are very large (many GBs). The model files themselves should not be part of any Git repo or Ansible role; the role should download them on first run.
# Traefik vs. NPM: Traefik is code-driven but has a steeper learning curve. Nginx Proxy Manager is easy but its configuration is in a database, making it harder to manage with pure IaC.
```

## Implementation Blueprint

### Data models and structure

Primary data structures will be configuration files:

- **Terraform:**terraform.tfvars will define VM specs (CPU, RAM, disk size) and network settings.
- **Ansible:**ansible/inventory/hosts.yml will define the hosts and groups. ansible/group\_vars/all.yml and role-specific vars/main.yml will manage service configurations, ports, and volume mounts. Sensitive information will be encrypted in vault files.

### list of tasks to be completed to fullfill the PRP in the order they should be completed

Yaml

```
# Phase 1: Foundation & IaC Setup
Task 1:
  CREATE ./ansible/ and ./terraform/ and ./packer/ directories.
  CREATE Git repository and add a .gitignore file (ignoring terraform.tfvars, .terraform*, ansible/vault_password.txt).
  COMMIT initial project structure.

Task 2:
  CREATE packer/ubuntu-22.04-lts.pkr.hcl:
    - Define a Proxmox builder connecting to the host.
    - Use an Ubuntu Server 22.04 ISO as the source.
    - Configure an unattended installation using cloud-init and an autoinstall config.
    - Add provisioners to update the OS, install the QEMU guest agent, and create a base user.
    - The final step should convert the resulting VM into a Proxmox template named "ubuntu-2204-cloudinit-template".

Task 3:
  CREATE terraform/main.tf, terraform/variables.tf:
    - Configure the Proxmox provider.
    - Define variables for Proxmox API credentials, node name, and default VM settings.
  CREATE terraform/vms/vm-test.tf:
    - Create a single \`proxmox_vm_qemu\` resource that clones the Packer template from Task 2.
    - Configure it with basic CPU/RAM and a cloud-init config for networking.
    - EXECUTE \`terraform apply\` to test that VM creation from the template works. Destroy it afterward.

Task 4:
  CREATE ansible/inventory/hosts.yml:
    - Define host groups (e.g., \`proxmox_vms\`, \`media_servers\`, \`home_automation\`).
  CREATE ansible/ansible.cfg to specify inventory path.
  CREATE ansible/roles/common/:
    - Tasks to perform system updates, install common packages (htop, git, etc.), and configure a non-root user with sudo.

# Phase 2: Core Services & Networking
Task 5:
  CREATE terraform/vms/vm-network.tf:
    - Define a VM for networking services (Pi-hole, Reverse Proxy).
  CREATE ansible/roles/networking/:
    - Task 1: Deploy Pi-hole + Unbound using a Docker Compose file.
    - Task 2: Deploy Traefik (or Nginx Proxy Manager) using Docker Compose.
  EXECUTE Terraform and Ansible to bring up core networking.
  CONFIGURE router to use Pi-hole as the DNS server and test ad-blocking.
  CONFIGURE port forwarding on the router to the reverse proxy VM (ports 80, 443).

Task 6:
  CREATE terraform/vms/vm-nas.tf and vm-nextcloud.tf.
  CREATE ansible/roles/nextcloud/:
    - Deploy Nextcloud, a database (Postgres/MariaDB), and Redis via Docker Compose.
    - Configure data volumes to be stored on the NAS (once available) or a dedicated ZFS volume.
  EXECUTE Terraform and Ansible to deploy Nextcloud.
  CONFIGURE the reverse proxy to expose Nextcloud with a valid SSL certificate.

# Phase 3: Media, Automation, and AI
Task 7:
  CREATE terraform/vms/vm-media.tf.
  CREATE ansible/roles/media_suite/ and ansible/roles/jellyfin/:
    - Use a single Docker Compose file in the media_suite role to deploy: Sonarr, Radarr, Prowlarr, qBittorrent, and Gluetun (VPN).
    - Configure network dependencies so qBittorrent's traffic is routed through Gluetun.
    - The jellyfin role deploys Jellyfin and configures its media libraries to point to NAS storage paths.
  EXECUTE Terraform and Ansible. Test the full media pipeline.

Task 8:
  CREATE terraform/vms/vm-home-automation.tf.
  CREATE ansible/roles/home_assistant/ and ansible/roles/frigate/:
    - The home_assistant role will deploy the Home Assistant OS VM (can be done via a helper script called by Ansible).
    - The frigate role will deploy the Frigate NVR Docker container, passing through the Coral TPU device if available. It will manage the frigate.yml configuration file.
  EXECUTE and integrate Frigate into Home Assistant.

Task 9:
  CREATE terraform/vms/vm-ai.tf.
  CREATE ansible/roles/llm_stack/:
    - Task 1: Deploy Ollama via its official installation script or Docker container.
    - Task 2: Pull a specific LLM model (e.g., llama2:13b).
    - Task 3: Deploy a Python script/service that uses LangChain to index the Obsidian vault into a vector store (FAISS) and expose a query endpoint.
  EXECUTE and test the RAG pipeline by asking questions related to the vault's content.

# Phase 4: Integration and Documentation
Task 10:
  INTEGRATE all services.
    - Configure Home Assistant automations based on Frigate events.
    - Set up n8n or Node-RED for custom workflows (e.g., email parsing, Discord notifications for media).
    - Test the full user experience from end-to-end.
  CREATE comprehensive documentation in the project's README.md or a dedicated wiki.
```

### Per task pseudocode as needed added to each task\`\`\`hcl

## Task 3 - Terraform VM Example (in terraform/vms/vm-test.tf)

resource "proxmox\_vm\_qemu" "test\_vm" {  
name = "test-vm"  
target\_node = var.proxmox\_node  
clone = "ubuntu-2204-cloudinit-template" # From Packer

## VM Resources

cores = 2  
sockets = 1  
memory = 2048

## Cloud-Init Configuration

os\_type = "cloud-init"  
ipconfig0 = "ip=dhcp" # Or static IP

## Ensure QEMU agent is enabled

agent = 1  
}

Yaml

```
# Task 7 - Ansible Media Suite Example (in ansible/roles/media_suite/tasks/main.yml)
- name: Create media stack directories
  file:
    path: "{{ item }}"
    state: directory
  loop:
    - "/opt/media-stack/config/sonarr"
    - "/opt/media-stack/config/radarr"
    # ... etc

- name: Deploy media stack with Docker Compose
  community.docker.docker_compose:
    project_src: /opt/media-stack/
    files:
      - docker-compose.yml
  notify: Restart media stack
\`\`\`

### Integration Points
\`\`\`yaml
# Backend Integration Points
NAS_STORAGE:
  - mount: Network shares (SMB/NFS) from the NAS VM will be mounted on other VMs.
  - paths: Nextcloud (for external data), Jellyfin (for media libraries), Frigate (for recordings), and the *arr suite (for downloads).

# Networking Integration Points
REVERSE_PROXY:
  - add to: Traefik's dynamic configuration file or Nginx Proxy Manager's API.
  - pattern: All web services (Nextcloud, Jellyfin, Sonarr, etc.) will be exposed via subdomains (e.g., nextcloud.home.lab).
  - ssl: Wildcard or individual Let's Encrypt certificates will be managed by the proxy.

INTERNAL_DNS:
  - add to: Pi-hole's "Local DNS Records".
  - pattern: Each service gets a DNS record pointing its hostname to its internal IP.

# Application Integration Points
HOME_ASSISTANT:
  - integration: Frigate (via MQTT and custom integration) for camera feeds and object detection events.
  - integration: Jellyfin/Plex for media playback status.
  - notifications: Send alerts to Discord/Mobile App based on events from other services.

AI_ASSISTANT:
  - data_source: The Obsidian vault, indexed into a vector database for RAG.
  - actions: The assistant will eventually be able to trigger Ansible playbooks or Home Assistant automations via API calls.
\`\`\`

## Validation Loop

### Level 1: Syntax & Style
\`\`\`bash
# Run these FIRST after making changes to the respective files.
# Terraform validation
cd terraform/ && terraform validate

# Packer validation
cd packer/ && packer validate .

# Ansible playbook syntax check and linting
cd ansible/ && ansible-playbook site.yml --syntax-check
cd ansible/ && ansible-lint
\`\`\`

## Final validation Checklist
- [ ] All Terraform plans execute without errors, and all VMs are created successfully.
- [ ] All Ansible playbooks run to completion without failures.
- [ ] All self-hosted services are accessible via their internal DNS names.
- [ ] All exposed services are accessible through the reverse proxy with valid HTTPS.
- [ ] A test file uploaded to Nextcloud syncs correctly.
- [ ] A movie can be requested in Radarr, downloaded by qBittorrent (through the VPN), and appears in Jellyfin for streaming.
- [ ] Home Assistant correctly shows camera feeds from Frigate and receives an event when a person is detected.
- [ ] The AI assistant can accurately answer a question based on content from the Obsidian vault.
- [ ] The Git repository is up-to-date with the final, working configuration.
```