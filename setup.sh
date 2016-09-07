#!/bin/bash

echo "****Aprovisionando la maquina"

echo "****Actualizando los repositorios"
sudo apt-get update -y
sudo apt-get upgrade -y

export JAVA_VERSION='8'
export JAVA_HOME='/usr/lib/jvm/java-8-oracle'

export MAVEN_VERSION='3.3.9'
export MAVEN_HOME='/usr/share/maven'
export PATH=$PATH:$MAVEN_HOME/bin

export TZ='Europe/Madrid'
export LANGUAGE='es_ES.UTF-8'
export LANG='es_ES.UTF-8'
export LC_ALL='es_ES.UTF-8'

echo "Europe/Madrid" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata
sudo locale-gen es_ES.UTF-8
sudo dpkg-reconfigure locales

# install utilities
echo "****Instalando utilidades"
sudo apt-get -y install git zip bzip2 fontconfig

################################################################################
# Install Java
################################################################################

echo "****Instalando Java"
# install Java 8
sudo echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list
sudo echo 'deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886

sudo apt-get update

sudo echo oracle-java-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install -y --force-yes oracle-java${JAVA_VERSION}-installer
sudo  update-java-alternatives -s java-8-oracle

echo "****Instalando Maven"
# install maven
sudo curl -fsSL http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | sudo tar xzf - -C /usr/share && sudo mv /usr/share/apache-maven-${MAVEN_VERSION} /usr/share/maven && sudo ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

echo "****Creando al usuario TIW"
#sudo addgroup tiw
sudo adduser --disabled-login --gecos "Tecnologias de Internet para la Web" tiw
echo 'tiw:tiw' | sudo chpasswd

################################################################################
# Install the graphical environment
################################################################################
echo "****Instalando entorno grafico"
# force encoding
echo 'LANG=es_ES.UTF-8' | sudo tee -a /etc/default/locale
echo 'LANGUAGE=es_ES.UTF-8' | sudo tee -a /etc/default/locale
echo 'LC_ALL=es_ES.UTF-8' | sudo tee -a /etc/default/locale
echo 'LC_CTYPE=es_ES.UTF-8' | sudo tee -a /etc/default/locale

# install languages
sudo apt-get install -y language-pack-es

echo "Permitiendo que cualquier usuario arranque el sistema grafico"
sudo sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config
# necesario para lxde
sudo mkdir /usr/share/backgrounds

sudo apt-get install -y lxde

# esto necesario para poder cerrar la maquina desde el gui
sudo gpasswd -a vagrant powerdev
sudo gpasswd -a tiw powerdev

#echo "session required pam_systemd.so" | sudo tee -a /etc/pam.d/lxdm

# instalacion de virtualbox-guest-guest-additions mediante el plugin vbguest 
#sudo apt-get install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11

#sudo apt-get install -y gdm
#sudo dpkg-reconfigure gdm

################################################################################
# Install the chromium browser
################################################################################

echo "****Instalando chromium-browser"
# install Chromium Browser
sudo apt-get install -y chromium-browser

################################################################################
# Install the MySQL
################################################################################

echo "****Instalando Mysql con password admin"
# install MySQL with default passwoard as 'admin'
export DEBIAN_FRONTEND=noninteractive
echo 'mysql-server mysql-server/root_password password admin' | sudo debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password admin' | sudo debconf-set-selections
sudo apt-get install -y mysql-server mysql-workbench

################################################################################
# Install the eclipse IDE
################################################################################

echo "****Instalando eclipse"

sudo wget -O /opt/eclipse-jee-mars-1-linux-gtk-x86_64.tar.gz http://ftp.fau.de/eclipse/technology/epp/downloads/release/mars/1/eclipse-jee-mars-1-linux-gtk-x86_64.tar.gz
cd /opt/ && sudo tar -zxvf eclipse-jee-mars-1-linux-gtk-x86_64.tar.gz
cd /opt && sudo rm -f eclipse-jee-mars-1-linux-gtk-x86_64.tar.gz
cd /home/tiw


echo "****Creando acceso directo a eclipse"
# create shortcuts
sudo mkdir -p /home/tiw/Desktop
sudo ln -s /opt/eclipse/eclipse /home/tiw/Desktop/eclipse
sudo chown -R tiw:tiw /home/tiw

echo "****Instalando Glassfish"

################################################################################
# Installing glassfish
################################################################################
sudo wget -O /opt/glassfish-4.1.1.zip http://download.java.net/glassfish/4.1.1/release/glassfish-4.1.1.zip
cd /opt && sudo unzip glassfish-4.1.1.zip
cd /opt/ && sudo rm -f glassfish-4.1.1.zip
echo "export PATH=/opt/glassfish4/bin:$PATH" | sudo tee -a /home/tiw/.profile
echo "AS_ADMIN_PASSWORD=" > /tmp/password.txt
echo "AS_ADMIN_NEWPASSWORD=admin" >> /tmp/password.txt
sudo /opt/glassfish4/bin/asadmin --user admin --passwordfile /tmp/password.txt change-admin-password --domain_name domain1
echo "AS_ADMIN_PASSWORD=admin" > /tmp/password.txt
cd /opt
sudo glassfish4/bin/asadmin start-domain && glassfish4/bin/asadmin --passwordfile /tmp/password.txt --host localhost --port 4848 enable-secure-admin && glassfish4/bin/asadmin stop-domain
sudo rm /tmp/password.txt
sudo chown -R tiw:tiw /opt



echo "****Limpiando la imagen"
# clean the box
sudo apt-get clean
dd if=/dev/zero of=/EMPTY bs=1M > /dev/null 2>&1
rm -f /EMPTY

#echo "Arreglando el error de dictionaries-common"
#/usr/share/debconf/fix_db.pl
#sudo apt-get install -y dictionaries-common
#sudo dpkg-reconfigure dictionaries-common

#echo "Solución al GD-Bus freedesktop operation not permitted"
#echo "session required pam_systemd.so" >> /etc/pam.d/lxdm

# echo "Instalando GDM"
# apt-get install -y gdm
# dpkg-reconfigure gdm



