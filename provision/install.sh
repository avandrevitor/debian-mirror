#!/bin/bash
# DEBIAN MIRROR ================================================================
# http://www.vivaolinux.com.br/artigo/Criando-mirror-do-Debian-Lenny-e-Debian-Lenny-Security-em-sua-rede-local

sudo -i

# GLOBAL VARS ==================================================================
SYSTEM_HOSTNAME="debian-mirror"
SYSTEM_IP="192.168.69.69"


# HOSTS ========================================================================
HOSTS=<<EOF
127.0.0.1       localhost
127.0.1.1       debian-mirror debian-mirror

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
echo $HOSTS >> /etc/hosts


# UPDATE =======================================================================
export DEBIAN_FRONTEND=noninteractive
echo "deb ftp://ftp.br.debian.org/debian/ wheezy main contrib non-free" >> /etc/apt/source.list
apt-get update --fix-missing    
apt-get -y install apt-mirror

# TIMEZONE =====================================================================
export TZ="America/Sao_Paulo"


# CONFIG =======================================================================
CONFIG=<<EOF
############# config ##################
#
# set base_path    /var/spool/apt-mirror
#
# if you change the base path you must create the directories below with write privlages
#
# set mirror_path  $base_path/mirror
# set skel_path    $base_path/skel
# set var_path     $base_path/var
# set cleanscript $var_path/clean.sh
# set defaultarch  <running host architecture>
# set nthreads     20
# set _tilde 0
#
############# end config ##############

set base_path /var/spool/apt-mirror
set mirror_path $base_path/mirror
set skel_path $base_path/skel
set var_path $base_path/var
set defaultarch i386

deb http://ftp.br.debian.org/debian/ wheezy main contrib non-free
deb-src http://ftp.br.debian.org/debian/ wheezy main contrib non-free
deb http://security.debian.org/debian-security wheezy/updates main contrib non-free
deb-src http://security.debian.org/debian-security wheezy/updates main contrib non-free

clean http://ftp.br.debian.org/
clean http://security.debian.org/
EOF
echo $CONFIG >> /etc/apt/mirror.list

# SETUP ========================================================================
apt-mirror /etc/apt/mirror.list



# APACHE2 ======================================================================
apt-get autoremove --purge -y  apache2 apache2.2-common apache2-doc apache2-mpm-prefork apache2-utils libmysqlclient15-dev php5 mysql-common
apt-get install -y apache2 apache2-utils apache2-mpm-prefork
a2enmod rewrite
echo "ServerName localhost" >> /etc/apache2/apache2.conf
echo "ServerName debian-mirror" >> /etc/apache2/apache2.conf
/etc/init.d/apache2 restart
update-rc.d apache2 defaults
chown -R www-data:vagrant /var/www

VHOST=<<EOF
Alias /debian/pool /var/spool/apt-mirror/mirror/ftp.br.debian.org/debian/pool
Alias /debian/dists /var/spool/apt-mirror/skel/ftp.br.debian.org/debian/dists
Alias /debian-security/pool /var/spool/apt-mirror/mirror/security.debian.org/debian-security/pool
Alias /debian-security/dists /var/spool/apt-mirror/skel/security.debian.org/debian-security/dists

<Directory /var/spool/apt-mirror/mirror/ftp.br.debian.org/debian/pool>
    AllowOverride None
    Options Indexes
    Order Deny,Allow
    Allow from $SYSTEM_IP
    Allow from 127.0.0.1/32
    Deny from all
</Directory>
<Directory /var/spool/apt-mirror/skel/ftp.br.debian.org/debian/dists/>
    AllowOverride None
    Options Indexes
    Order Deny,Allow
    Allow from $SYSTEM_IP
    Allow from 127.0.0.1/32
</Directory>
<Directory /var/spool/apt-mirror/mirror/security.debian.org/debian-security/pool>
    AllowOverride None
    Options Indexes
    Order Deny,Allow
    Allow from $SYSTEM_IP
    Allow from 127.0.0.1/32
    Deny from all
</Directory>
<Directory /var/spool/apt-mirror/skel/security.debian.org/debian-security/dists/>
    AllowOverride None
    Options Indexes
    Order Deny,Allow
    Allow from $SYSTEM_IP
    Allow from 127.0.0.1/32
    Deny from all
</Directory>
EOF
echo $VHOST >> /etc/apache2/conf.d/apt-repository.conf

service apache2 restart


# SHOW #########################################################################
apt-get install -y lsb-release scrot
cd ~./
wget http://github.com/downloads/djmelik/archey/archey-0.2.8.deb
dpkg -i archey-0.2.8.deb
rm archey-0.2.8.deb
cls
archey