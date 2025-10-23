# Dokploy Terraform Deployment

With this project you can provision a Hetzner VPS with [Dokploy](https://dokploy.com/) pre-installed using Terraform.

**What is Dokploy?**

An open-source, self-hosted Platform-as-a-Service (PaaS) that simplifies application deployment, database management, and server configuration through a web UI and CLI.

**Why this project?**

By combining Terraform with Dokploy, you get:

- **Infrastructure as Code**: Reproducible server provisioning which you can include in your version control
- **Easy Deployment**: Use Dokploy's UI/CLI to manage your applications after initial setup

Additionally:

- **Server hardening and added security**: SSH is hardened and root login is disabled by default. Only clients with the configured SSH key can access the server. To skip this step, remove the remote-exec line that runs `ssh_init.sh` in `main.tf`.

## Table of Contents

- [Default VPS Configuration](#default-vps-configuration)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Accessing the Server](#accessing-the-server)
- [Cleaning Up](#cleaning-up)

## Default VPS Configuration

The VPS will be provisioned with the following settings (configurable in `main.tf`):

```tf
server_type  = "cx23"
image        = "docker-ce"
location     = "fsn1"
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- [Hetzner Cloud](https://www.hetzner.com/) account with:
  - Activated account
  - IPv4 primary IP named "dokploy-ip"
  - [API token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/)
  - **Optional:** Firewall rules (add to `main.tf` under `firewall_ids`)

## Setup Instructions

### 1. Create SSH Key

Generate SSH keys for server provisioning and access:

```bash
mkdir -p ~/.ssh/dokploy
ssh-keygen -t ed25519 -C "dokploy" -f ~/.ssh/dokploy/id_ed25519
```

The SSH keys will be stored in `~/.ssh/dokploy/` on your local machine.

### 2. Configure Hetzner API Token

Once you've acquired your [Hetzner API token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/), store it in the root directory of this project:

```bash
echo "your-api-token-here" > hetzner-token.txt
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Provision the Server

```bash
terraform fmt
terraform validate
terraform apply
```

This will:

- Create a new server on Hetzner Cloud
- Disable root user and apply SSH hardening
- Install Dokploy

Upon successful completion, you'll see:

```bash
hcloud_server.dokploy-manager (remote-exec): Congratulations, Dokploy is installed!
hcloud_server.dokploy-manager (remote-exec): Please go to http://<your-ip>:3000
```

> **Note:** Your server's firewall should expose port 3000 otherwise Dokploy will not be accessible.

## Accessing the Server

### From the browser

Dokploy should be available under `http://<your-ip>:3000`

After registering, set a server domain and enable HTTPS under Web Server > Server Domain, then route your traffic through that domain. For a walkthrough on setting up a domain and configuring Dokploy, watch [this video](https://youtu.be/ELkPcuO5ebo?si=nx-7Eo5yqnZMG_AH&t=596).

**Important:** Once you've configured your server's domain and enabled , make sure to change the password that you made over HTTP, because it was not created over an encrypted connection.

### Via SSH

```bash
ssh -i ~/.ssh/dokploy/id_ed25519 dokploy@<your-ip>
```

### Via VS Code Remote SSH

1. Open VS Code
2. Select **Remote-SSH: Connect to Host...**
3. Choose **Configure SSH Hosts...**
4. Add the following configuration:

```config
Host DOKPLOY_MANAGER
  HostName <your-ip>
  Port 22
  User dokploy
  IdentityFile ~/.ssh/dokploy/id_ed25519
```

You can now open a remote window:

1. Select **Remote-SSH: Connect to Host...**
2. Select **DOKPLOY_MANAGER**

You should now be connected to the remote host!

### Troubleshooting

**"REMOTE HOST IDENTIFICATION HAS CHANGED"** or **"Host key verification failed."**

This error occurs because you previously connected to a different server at this IP address, and now SSH detects a different host key. This is expected when you destroy and recreate servers with Terraform.

To fix this, remove the old host key from your known_hosts file:

```bash
$ ssh-keygen -R <your-ip>
```

## Cleaning Up

To destroy all resources created by Terraform:

```bash
terraform destroy
```

**Warning:** This will permanently delete your server and all data on it.

> **Note:** If there's a problem with cleaning up the resource automatically, make sure to clean up the known hosts on your local machine and SSH key for this project under `Hetzner Console > Security > SSH keys`.
