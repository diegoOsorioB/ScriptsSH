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

echo "===> Instalando RVM..."
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable

# Cargar RVM
source ~/.rvm/scripts/rvm

# Comprobar si RVM se cargó bien
if ! command -v rvm &>/dev/null; then
    echo "❌ RVM no está disponible. Revisa la instalación."
    exit 1
fi

echo "===> Verificando Ruby 2.6.10..."
if ! rvm list | grep -q "ruby-2.6.10"; then
    echo "===> Instalando Ruby 2.6.10..."
    rvm install 2.6.10 --with-openssl-dir=/usr/local/ssl
else
    echo "Ruby 2.6.10 ya está instalado."
fi

rvm use 2.6.10 --default

echo "===> Instalando Bundler y Rails..."
gem install bundler -v 2.1.4
gem install rails -v 5.2.4

echo "===> Clonando repositorio de Fedena..."
cd ~
if [ -d "fedena" ]; then
    echo "⚠️ Ya existe la carpeta ~/fedena. No se volverá a clonar."
else
    git clone https://github.com/projectfedena/fedena.git
fi
cd fedena

echo "===> Verificando disponibilidad de bundle..."
if ! command -v bundle &>/dev/null; then
    echo "❌ El comando 'bundle' no está disponible. Asegúrate de que Ruby y Bundler estén bien instalados."
    exit 1
fi

echo "===> Instalando dependencias Ruby..."
bundle install

echo "===> Configurando base de datos..."
cp -n config/database.yml.example config/database.yml

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
