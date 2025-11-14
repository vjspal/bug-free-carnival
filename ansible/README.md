# Ansible Configuration

This directory contains Ansible playbooks and roles for configuring the home lab infrastructure.

## Prerequisites

1. **Ansible installed** (>= 2.15)
2. **SSH access** to all target hosts
3. **Sudo privileges** on target hosts

## Initial Setup

### 1. Install Ansible

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# Or via pip
pip install ansible
```

### 2. Set Up Vault Password

```bash
# Create vault password file (gitignored)
echo "your-strong-password-here" > vault_password.txt
chmod 600 vault_password.txt

# Create encrypted vault
ansible-vault create group_vars/vault.yml

# Add your secrets (refer to group_vars/vault.yml.example)
```

### 3. Configure SSH Keys

Ensure your SSH public key is added to target hosts (done automatically by Packer/cloud-init).

```bash
# Test connectivity
ansible all -m ping

# If needed, manually add your key to a host
ssh-copy-id admin@192.168.1.xxx
```

## Usage

### Test Connectivity

```bash
ansible all -m ping
```

### Run Playbook (Dry Run)

```bash
ansible-playbook playbooks/site.yml --check
```

### Run Playbook

```bash
ansible-playbook playbooks/site.yml
```

### Run Specific Roles

```bash
# Only run common role
ansible-playbook playbooks/site.yml --tags common

# Run on specific host group
ansible-playbook playbooks/site.yml --limit automation
```

### Ad-hoc Commands

```bash
# Check disk space
ansible all -m shell -a "df -h"

# Update all packages
ansible all -m apt -a "update_cache=yes upgrade=dist" --become

# Restart a service
ansible automation -m service -a "name=docker state=restarted" --become
```

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── inventory/
│   └── hosts.yml            # Inventory of all hosts
├── group_vars/
│   ├── all.yml              # Variables for all hosts
│   └── vault.yml            # Encrypted secrets (create with ansible-vault)
├── playbooks/
│   └── site.yml             # Main playbook
├── roles/
│   ├── common/              # Base system configuration
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   └── handlers/
│   │       └── main.yml
│   ├── docker/              # Docker installation
│   │   └── tasks/
│   │       └── main.yml
│   └── ...                  # Service-specific roles (to be added)
└── README.md                # This file
```

## Available Roles

### common
**Purpose**: Base system configuration for all hosts
**Tasks**:
- Set timezone
- Update packages
- Install common utilities
- Configure SSH (disable root, disable password auth)
- Create admin user with sudo
- Enable automatic security updates

**Usage**:
```yaml
roles:
  - common
```

### docker
**Purpose**: Install Docker and Docker Compose
**Tasks**:
- Add Docker repository
- Install Docker CE and plugins
- Add users to docker group
- Create Docker networks (proxy, internal)

**Usage**:
```yaml
roles:
  - docker
```

## Creating a New Role

```bash
# Create role structure
ansible-galaxy init roles/myservice

# Or manually
mkdir -p roles/myservice/{tasks,handlers,files,templates,vars,defaults}
```

Example `roles/myservice/tasks/main.yml`:
```yaml
---
- name: Create service directory
  file:
    path: /opt/myservice
    state: directory
    mode: '0755'

- name: Deploy docker-compose file
  template:
    src: docker-compose.yml.j2
    dest: /opt/myservice/docker-compose.yml
    mode: '0644'
  notify: restart myservice

- name: Start service
  community.docker.docker_compose:
    project_src: /opt/myservice
    state: present
```

## Ansible Vault

### Create New Vault

```bash
ansible-vault create group_vars/vault.yml
```

### Edit Existing Vault

```bash
ansible-vault edit group_vars/vault.yml
```

### View Vault Contents

```bash
ansible-vault view group_vars/vault.yml
```

### Change Vault Password

```bash
ansible-vault rekey group_vars/vault.yml
```

## Best Practices

1. **Always use `--check` first** to see what would change
2. **Use tags** to run specific parts of playbooks
3. **Keep secrets in vault** - never commit plaintext passwords
4. **Use handlers** for service restarts
5. **Make tasks idempotent** - safe to run multiple times
6. **Document variables** in role defaults or README

## Common Issues

### "Permission denied" errors
- Ensure your SSH key is on the target host
- Check that the admin user has sudo access

### "Host unreachable"
- Verify host is running: `ping 192.168.1.xxx`
- Check inventory file has correct IP addresses
- Ensure SSH is running on target host

### "Vault password not found"
- Create `vault_password.txt` with your vault password
- Or use `--ask-vault-pass` flag

### Playbook hangs on "Gathering Facts"
- SSH to the host manually first to accept host key
- Or set `host_key_checking = False` in ansible.cfg

## Integration with Terraform

Typical workflow:
1. **Terraform** provisions VMs
2. **Wait** for cloud-init to complete (~2-3 minutes)
3. **Verify** SSH access to new VM
4. **Add** VM to `inventory/hosts.yml`
5. **Run** Ansible playbook to configure

## Integration with Semaphore

Once Semaphore is deployed (Phase 1):
1. Connect Semaphore to Gitea repository
2. Create project in Semaphore
3. Add inventory and playbooks
4. Run playbooks via Semaphore web UI

## Next Steps

1. **Create vault** with your secrets
2. **Add hosts** to inventory as they're provisioned
3. **Test connectivity** with `ansible all -m ping`
4. **Run playbook** to configure hosts
5. **Create service-specific roles** as needed

---

For more details, see the main [README.md](../README.md) and [SERVICE_CATALOG.md](../SERVICE_CATALOG.md).
