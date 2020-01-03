#!/bin/sh
#Installs and configures OpenShift and necessary packages.

# Check if oc installed
if [[ -x "$(command -v oc)" ]]; then
  echo "*** oc is installed"
  oc version
  exit 0
fi

# Default versions
if [[ -z "$OC_VERSION" || -z "$OC_HASH" ]]; then
  export OC_VERSION="3.11.0"
  export OC_HASH="0cbc58b"
  echo "*** Referring to default OpenShift version v$OC_VERSION-$OC_HASH"
fi

# Ensuring that the firewall allows containers access to the OpenShift master API (8443/tcp) and DNS (53/udp) endpoints.
DOCKER_BRIDGE=`docker network inspect -f "{{range .IPAM.Config }}{{ .Subnet }}{{end}}" bridge`
sudo firewall-cmd --permanent --new-zone dockerc
sudo firewall-cmd --permanent --zone dockerc --add-source $DOCKER_BRIDGE
sudo firewall-cmd --permanent --zone dockerc --add-port={80,443,8443}/tcp
sudo firewall-cmd --permanent --zone dockerc --add-port={53,8053}/udp
sudo firewall-cmd --reload

# Installing packages
echo "*** Installing OpenShift version $OC_VERSION"

sudo yum install wget -y
wget -q "https://github.com/openshift/origin/releases/download/v$OC_VERSION/openshift-origin-client-tools-v$OC_VERSION-$OC_HASH-linux-64bit.tar.gz"
tar xvf openshift-origin-client-tools*.tar.gz 2> /dev/null
cd openshift-origin-client*/
sudo mv oc kubectl /usr/bin/

# Verify version
echo "*** Verifying installation..."
oc version

echo "*** Starting cluster..."
oc cluster up