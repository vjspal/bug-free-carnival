# homelaby todo PRD
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
    - Create a single `proxmox_vm_qemu` resource that clones the Packer template from Task 2.
    - Configure it with basic CPU/RAM and a cloud-init config for networking.
    - EXECUTE `terraform apply` to test that VM creation from the template works. Destroy it afterward.

Task 4:
  CREATE ansible/inventory/hosts.yml:
    - Define host groups (e.g., `proxmox_vms`, `media_servers`, `home_automation`).
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