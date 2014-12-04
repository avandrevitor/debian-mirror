# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = "debian-mirror"
  config.vm.box = "puphpet/debian75-x32"
  config.vm.network "private_network", ip: "192.168.69.69"

  config.vm.synced_folder "./", "/var/www"
  config.vm.synced_folder "./mirror/", "/var/spool/apt-mirror"

  config.vm.provision "shell", path: "./provision/install.sh"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
  end

end
