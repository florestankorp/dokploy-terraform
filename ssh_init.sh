#!/bin/bash
ssh_init() {
    # Disable password authentication and login as "root"
    sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
    sudo sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

    # Restart SSH
    systemctl restart ssh.service
}

ssh_init