#!/bin/bash

echo "===> Instalando RVM y Ruby..."
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

\curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 2.6.10 --with-openssl-dir=/usr/include/openssl
rvm use 2.6.10 --default

echo "===> Instalando Bundler y Rails..."
gem install bundler
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

echo "✅ Script de usuario completado. Ahora accede a http://tu_servidor para terminar la configuración."
