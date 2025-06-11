#!/bin/bash

echo "===> Instalando dependencias del sistema (debes haberlas instalado como root antes)..."
# Este paso debe haberse hecho previamente como root: curl, git, etc.

echo "===> Instalando RVM (Ruby Version Manager)..."
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable

echo "===> Cargando RVM..."
source ~/.rvm/scripts/rvm

echo "===> Instalando Ruby 2.6.10 localmente..."
rvm install 2.6.10 --default

echo "===> Instalando Bundler y Rails localmente..."
gem install bundler -v 2.1.4
gem install rails -v 5.2.4

echo "===> Clonando repositorio de Fedena..."
cd ~
if [ -d "fedena" ]; then
  echo "⚠️  La carpeta ~/fedena ya existe. No se clonará de nuevo."
else
  git clone https://github.com/projectfedena/fedena.git
fi
cd ~/fedena

echo "===> Instalando dependencias Ruby (bundle)..."
bundle install

echo "===> Configurando base de datos..."
cp config/database.yml.example config/database.yml

echo "⚠️  Abre config/database.yml y edita con tus credenciales:"
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
