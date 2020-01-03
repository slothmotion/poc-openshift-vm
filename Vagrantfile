# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"
  config.vm.box_version = "1905.1"
  config.vm.box_check_update = false

  # Host-only access
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.define "centos7-vm", primary: true do |centos|
  
    centos.vm.provider "virtualbox" do |vb|
      vb.name = "centos7-vm"
      vb.gui = false
      vb.memory = "4096"
      vb.cpus = 1
    
      # disabling the logging into Vagrantfile's parent folder
      vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
    end

  end

  # OpenShift cluster
  config.vm.network "forwarded_port", guest: 8443, host: 8443, host_ip: "127.0.0.1"
  
  # TRIGGERS
  
  # shutting down oc cluster
  config.trigger.before :halt do |trigger|
    trigger.run_remote = {inline: <<-SHELL
      echo "*** Stopping oc cluster..."
      oc cluster down
      SHELL
    }
  end
  
  # shutting down docker containers
  config.trigger.before :halt do |trigger|
    trigger.run_remote = {inline: <<-SHELL
      echo "*** Stopping the docker containers..."
      containers=$(docker ps -a -q)
      if [ ! -z "$containers" ]; then
	    docker stop $containers
	  fi
      SHELL
    }
  end

  # PROVISIONING: 'vagrant up' executes by default, for re-run: 'vagrant provision'

  # installing binaries
  config.vm.provision "shell", path: "install-docker.sh"
  config.vm.provision "shell", path: "install-oc.sh"

end
