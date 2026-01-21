#!/bin/bash

check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "❌ Execute como root ou sudo!"
    exit 1
  fi
}

set_hostname() {
  new_hostname="server-ubuntu"
  hostnamectl set-hostname "$new_hostname"
  echo "🌐 Hostname definido para: $new_hostname"
}

set_timezone() {
  timezone="America/Sao_Paulo"
  timedatectl set-timezone "$timezone"
  echo "⏰ Timezone configurada para: $timezone"
}

update_system() {
  echo "🔄 Atualizando sistema..."
  apt update -y
  apt upgrade -y
  echo "✅ Sistema atualizado!"
}

configure_firewall() {
  echo "🛡️ Configurando firewall com UFW..."
  ufw --force enable
  ufw allow ssh
  ufw allow http
  ufw reload
  echo "✅ Firewall pronto!"
}

clear
echo "🚀 Iniciando setup básico do servidor Ubuntu🚀"
check_root
set_hostname
set_timezone
update_system
configure_firewall
echo "🎉 Setup finalizado! Você pode reiniciar o servidor se quiser."
