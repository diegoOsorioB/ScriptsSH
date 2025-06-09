#!/bin/bash

echo "===> Instalando dependencias del sistema..."
sudo apt-get update
sudo apt-get install -y build-essential checkinstall zlib1g-dev git curl libpq-dev nodejs

echo "===> Compilando OpenSSL 1.1.1..."
wget https://www.openssl.org/source/openssl-1.1.1w.tar.gz
tar -xzf openssl-1.1.1w.tar.gz
cd openssl-1.1.1w
./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib
make
sudo make install
cd ..

# Configurar enlaces simbólicos
sudo ln -sf /usr/local/ssl/lib/libssl.so.1.1 /usr/lib/libssl.so.1.1
sudo ln -sf /usr/local/ssl/lib/libcrypto.so.1.1 /usr/lib/libcrypto.so.1.1
echo "/usr/local/ssl/lib" | sudo tee /etc/ld.so.conf.d/openssl-1.1.conf
sudo ldconfig

echo "===> Instalando RVM y Ruby..."
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm

echo "===> Instalando Ruby 2.6.10 con OpenSSL 1.1..."
rvm install 2.6.10 --with-openssl-dir=/usr/local/ssl
rvm use 2.6.10 --default

echo "===> Instalando Bundler y Rails..."
gem install bundler -v 2.1.4
gem install rails -v 5.2.4

echo "===> Clonando repositorio de Fedena..."
cd ~
git clone https://github.com/projectfedena/fedena.git
cd fedena

echo "===> Instalando dependencias Ruby..."
bundle install

echo "===> Configurando base de datos..."
cp config/database.yml.example config/database.yml

echo "⚠️ Abre config/database.yml y edita con tus credenciales:"
echo "   username: fedena_user"
echo "   password: password_seguro"
read -p "Presiona ENTER cuando hayas terminado de editar config/database.yml..."

nano config/database.yml

echo "===> Creando y migrando base de datos..."
RAILS_ENV=production bundle exec rake db:create
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake db:seed

echo "===> Precompilando assets..."
RAILS_ENV=production bundle exec rake assets:precompile

echo "✅ Instalación completada. Accede a http://$(hostname -I | awk '{print $1}') para terminar la configuración."