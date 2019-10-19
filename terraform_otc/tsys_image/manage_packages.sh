#!/bin/bash

# Install EPEL repo
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarc
h.rpm

# Install most current patch level on image
sudo yum -y update

# Install EPEL repo
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarc
h.rpm

# Install additional tools
#yum -y install \
# open-vm-tools \

# Update system
yum -y update

# Enable SSH keepalive
sed -i 's/^#\(ClientAliveInterval\).*$/\1 180/g' /etc/ssh/sshd_config

# Disable GSS API calls
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_confi
g


# from service
sudo yum remove mariadb-libs mariadb-common mariadb-config -y
sudo yum install mysql nfs-utils -y

# HAproxy is contained in each Baseimage, but disabled until really used
sudo yum install haproxy -y
sudo systemctl stop haproxy
sudo systemctl disable haproxy


