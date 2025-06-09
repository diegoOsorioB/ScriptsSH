#!/bin/bash

echo "===> Actualizando sistema..."
apt update && apt upgrade -y

echo "===> Instalando paquetes necesarios..."
apt install -y curl gpg git build-essential libssl-dev libreadline-dev zlib1g-dev libyaml-dev libcurl4-openssl-dev libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev libtool libxml2-dev libxslt1-dev apache2 libapache2-mod-passenger mariadb-server mariadb-client firewalld fail2ban

echo "===> Configurando base de datos MariaDB..."
mysql_secure_installation

echo "===> Creando base de datos y usuario para Fedena..."
mysql -u root -p <<EOF
CREATE DATABASE fedena CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'fedena_user'@'localhost' IDENTIFIED BY 'password_seguro';
GRANT ALL PRIVILEGES ON fedena.* TO 'fedena_user'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "===> Creando usuario fedena si no existe..."
id -u fedena &>/dev/null || adduser fedena
usermod -aG sudo fedena

echo "===> Habilitando módulos de Apache..."
a2enmod passenger
a2enmod rewrite

echo "===> Creando VirtualHost para Fedena..."
cat > /etc/apache2/sites-available/fedena.conf <<EOF
<VirtualHost *:80>
    ServerName tu_dominio_o_ip
    DocumentRoot /home/fedena/fedena/public

    <Directory /home/fedena/fedena/public>
        Require all granted
        Options -MultiViews
        AllowOverride All
    </Directory>

    PassengerRuby /home/fedena/.rvm/gems/ruby-2.6.10/wrappers/ruby
    PassengerAppEnv production
</VirtualHost>
EOF

a2ensite fedena
a2dissite 000-default
systemctl restart apache2

echo "===> Configurando firewalld y fail2ban..."
systemctl enable --now firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

systemctl enable --now fail2ban

echo "===> Asignando permisos al directorio de Fedena..."
chown -R fedena:fedena /home/fedena/fedena

echo "✅ Script root completado. Ahora ejecuta el script como usuario 'fedena'."
