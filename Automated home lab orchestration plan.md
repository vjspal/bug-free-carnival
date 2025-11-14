---
date:
tags:#🌱, #homelaby
---


title: Homelab Orchestration PRD
created: 2025-10-29
tags:
  - homelab
  - IaC
  - proxmox
  - terraform
  - packer
  - ansible
  - self-hosted
  - AI
aliases:
  - Automated Home Lab Orchestration Plan
status: draft
owner: VJ Pal
---

# Homelab Orchestration — Product Requirements Document (PRD)

> [!summary] Executive Snapshot
> Build a stable, modular **homelab platform** that can **spin up/tear down services on demand**, showcase projects via a **blog/portfolio**, host **local AI agents**, automate **media acquisition & management**, integrate **NVR/Frigate**, provide **internal DNS + reverse proxy**, enable **business workflows** (email automations, NLP parsing, YouTube/infographic “wisdom extraction”), and **integrate with Obsidian** via a local **RAG** pipeline. Provisioning is reproducible with **Packer + Terraform (optional) + Ansible** and documented end-to-end.

---

## Table of Contents
- [[#Goals & Primary Use Cases|Goals & Primary Use Cases]]
- [[#System Architecture Overview|System Architecture Overview]]
  - [[#Core Tooling|Core Tooling]]
  - [[#Source-of-Truth & Git Repos|Source-of-Truth & Git Repos]]
- [[#Networking & Access|Networking & Access]]
- [[#Service Catalog|Service Catalog]]
  - [[#Storage  Cloud|Storage & Cloud]]
  - [[#Media Suite|Media Suite]]
  - [[#Home Automation  Security|Home Automation & Security]]
  - [[#Productivity  Business Apps|Productivity & Business Apps]]
  - [[#Local AI  Obsidian RAG|Local AI & Obsidian RAG]]
- [[#Implementation Plan|Implementation Plan]]
- [[#Code Skeletons|Code Skeletons]]
- [[#Observability  Security|Observability & Security]]
- [[#Future Enhancements|Future Enhancements]]
- [[#Appendix|Appendix]]

---

## Goals & Primary Use Cases
- **Learning & Experimentation:** Reproducible, disposable environments for rapid trials.
- **Public Portfolio:** Auto-generated docs → blog/website to build credibility.
- **Local-First AI:** Run LLM(s) locally; agentic tasks on request (Discord/CLI/UI).
- **Media Replacement:** Jellyfin/Plex + *Arr suite + VPN’d downloads + Calibre/Readarr.
- **Smart Home/NVR:** Home Assistant + Frigate (object/face recognition) + automations.
- **Networking:** Internal DNS (Unbound/Pi-hole), reverse proxy (Traefik/NPM) with SSL.
- **Business Workflows:** Email/Discord automations, NLP date parsing, YT/infographic extraction, PM/CRM.
- **PKM Integration:** Obsidian ↔ Local RAG (embeddings + retrieval → grounded answers).

> [!tip] Success Criteria
> - New service = code PR + one command → online behind HTTPS + documented.
> - “Ask the lab” style commands via Discord/CLI to trigger infra/service automations.
> - Portfolio auto-publishes change logs, diagrams, and “what I learned” posts.

---

## System Architecture Overview

### Core Tooling
- **Proxmox VE** — virtualization base (VMs/LXCs, bridges/VLANs).
- **Packer** — build golden VM templates (cloud-init enabled).
- **Terraform** *(optional)* — declarative VM/LXC creation from Packer templates.
- **Ansible** — idempotent service configuration & lifecycle.
- **Reverse Proxy** — **Traefik** (as-code) or **Nginx Proxy Manager** (simplicity).
- **Internal DNS** — **Unbound** (+ **Pi-hole** if you want network-wide filtering).
- **Workflow Automations** — **n8n** / Node-RED.
- **LLM Hosting** — **Ollama** / text-gen-webui / OpenWebUI.
- **Dashboards** — Homarr/Flame/Heimdall for quick links.

### Source-of-Truth & Git Repos
- `infra/packer/…` — template definitions.
- `infra/terraform/…` — Proxmox resources (VMs/LXCs, networks).
- `infra/ansible/…` — roles, inventories, group_vars, vault secrets.
- `apps/compose/…` — docker-compose for app stacks (media, n8n, etc.).
- `docs/` — Obsidian vault content + export scripts → blog/portfolio.

```mermaid
flowchart LR
  subgraph Proxmox Host
    direction TB
    VM_Packer[VM Template<br/>(Packer + Cloud-Init)]
    VM_DNS[DNS (Unbound/Pi-hole)]
    VM_RP[Reverse Proxy (Traefik/NPM)]
    VM_AI[LLM/API (Ollama/OpenWebUI)]
    VM_MEDIA[Media Stack (*Arr + qBittorrent+Gluetun + Jellyfin)]
    VM_NAS[NAS (OMV) + Shares]
    VM_HA[Home Assistant]
    VM_FRIGATE[Frigate NVR]
    VM_BIZ[OpenProject/Wiki/CRM]
    VM_AUTOMATE[n8n / Node-RED]
  end

  User[User / Discord / CLI] --> VM_RP
  VM_RP --> VM_MEDIA
  VM_RP --> VM_BIZ
  VM_RP --> VM_AI
  VM_RP --> VM_HA
  VM_RP --> VM_FRIGATE
  VM_RP --> VM_DNS

  VM_MEDIA --- VM_NAS
  VM_FRIGATE --- VM_NAS
  VM_AI --- Obsidian[(Obsidian Vault<br/>RAG Index)]