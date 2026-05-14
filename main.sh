#!/bin/bash

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "execute como root ou com sudo"
        exit 1
    fi
}

set_hostname() {
    hostnamectl set-hostname "server-ubuntu"
}

set_timezone() {
    timedatectl set-timezone "America/Sao_Paulo"
}

update_system() {
    apt update -y && apt upgrade -y
    apt install -y curl wget git unzip htop net-tools ufw fail2ban
}

configure_ssh() {
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config

    echo "MaxAuthTries 3" >> /etc/ssh/sshd_config
    echo "LoginGraceTime 30" >> /etc/ssh/sshd_config

    systemctl restart ssh
}

configure_firewall() {
    ufw --force enable
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow http
    ufw allow https
    ufw reload
}

configure_fail2ban() {
    cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
EOF

    systemctl enable fail2ban
    systemctl restart fail2ban
}

configure_swap() {
    if ! swapon --show | grep -q /swapfile; then
        fallocate -l 2G /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo '/swapfile none swap sw 0 0' >> /etc/fstab

        echo 'vm.swappiness=10' >> /etc/sysctl.conf
        sysctl -p
    fi
}

install_docker() {
    apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null

    apt install -y ca-certificates gnupg lsb-release

    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt update -y
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    systemctl enable docker
    systemctl start docker

    if [ -n "$SUDO_USER" ]; then
        usermod -aG docker "$SUDO_USER"
    fi
}

configure_limits() {
    cat >> /etc/security/limits.conf <<EOF
* soft nofile 65536
* hard nofile 65536
EOF

    cat >> /etc/sysctl.conf <<EOF
net.core.somaxconn=65535
net.ipv4.tcp_max_syn_backlog=65535
EOF

    sysctl -p
}

cleanup() {
    apt autoremove -y
    apt autoclean -y
}

check_root
set_hostname
set_timezone
update_system
configure_ssh
configure_firewall
configure_fail2ban
configure_swap
install_docker
configure_limits
cleanup

echo "setup concluido. reinicie o servidor para aplicar todas as configuracoes."
