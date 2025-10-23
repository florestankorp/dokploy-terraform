terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    version = "1.54.0" }
  }
}

provider "hcloud" {
  token = file("hetzner-token.txt")
}

resource "hcloud_ssh_key" "dokploy_ssh_key" {
  name       = "dokploy_ssh_key"
  public_key = file("~/.ssh/dokploy/id_ed25519.pub")
}

data "hcloud_primary_ip" "dokploy-ip" {
  name = "dokploy-ip"
}

resource "hcloud_server" "dokploy" {
  name         = "dokploy"
  server_type  = "cx23"
  image        = "docker-ce"
  location     = "fsn1"
  ssh_keys     = [hcloud_ssh_key.dokploy_ssh_key.id]
  firewall_ids = [] # add your firewall ID's here to apply during provisioning

  public_net {
    ipv4 = data.hcloud_primary_ip.dokploy-ip.id
  }

  # Create directory first
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("~/.ssh/dokploy/id_ed25519")
      host        = self.ipv4_address
    }
    inline = [
      "mkdir -p /opt/dokploy"
    ]
  }

  # Copy scripts
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("~/.ssh/dokploy/id_ed25519")
      host        = self.ipv4_address
    }
    source      = "./ssh_init.sh"
    destination = "/opt/dokploy/ssh_init.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("~/.ssh/dokploy/id_ed25519")
      host        = self.ipv4_address
    }

    inline = [
      "sh /opt/dokploy/ssh_init.sh",
      "rm -rf /opt/dokploy",
      "curl -sSL https://dokploy.com/install.sh | sh"
    ]
  }
}
