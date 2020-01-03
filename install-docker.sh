#!/bin/sh
#Installs and configures Docker and necessary packages.

# Checks if docker installed
if [[ -x "$(command -v docker)" ]]; then
  echo "*** docker is installed"
  docker version
  exit 0
fi

# Default versions
if [[ -z "$DOCKER_VERSION" ]]; then
  export DOCKER_VERSION="19.03.5-3.el7"
  echo "*** Referring to default Docker version $DOCKER_VERSION"
fi

if [[ -z "$CONTAINERD_VERSION" ]]; then
  export CONTAINERD_VERSION="1.2.6-3.3.el7"
  echo "*** Referring to default containerd version $CONTAINERD_VERSION"
fi

# Installing packages
echo "*** Installing Docker version $DOCKER_VERSION"

sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y  docker-ce-$DOCKER_VERSION docker-ce-cli-$DOCKER_VERSION containerd.io-$CONTAINERD_VERSION

# Adding user account to docker group
sudo usermod -aG docker $USER
newgrp docker

# Defining local image registry
sudo mkdir /etc/docker /etc/containers

sudo tee /etc/containers/registries.conf<<EOF
[registries.insecure]
registries = ['172.30.0.0/16']
EOF

sudo tee /etc/docker/daemon.json<<EOF
{
   "insecure-registries": [
     "172.30.0.0/16"
   ]
}
EOF

# Restart docker daemon
sudo systemctl daemon-reload
sudo systemctl restart docker

# Start docker after init
sudo systemctl enable docker

