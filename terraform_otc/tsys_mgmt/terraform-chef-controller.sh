#!/bin/sh

# generally, use /tmp as working directory
cd /tmp

# add Fedora epel repository (REDHAT7+)
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo subscription-manager repos --enable "rhel-*-optional-rpms" --enable "rhel-*-extras-rpms"

# patch CentOS to most frequent level
sudo yum -y update

# prepare to build a current version of ansible (>= 2.0) to support OpenStack
# psycopg2 for Postgres installation
sudo yum --enablerepo=epel -y install make rpm-build python2-devel python-psycopg2 python-pip asciidoc git expect vim nano libffi-devel openssl-devel java-1.8.0-openjdk-devel jq

# install OpenStack shade client lib to control the OpenStack by API
# work around a problem with "requests" in pip,downgrade and upgrade afterwards
sudo pip install --upgrade --force-reinstall pip==9.0.3
sudo pip install shade python-openstackclient
sudo pip install --upgrade pip

# install terraform
curl https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip > /tmp/terraform.zip
sudo unzip -o -d /usr/local/bin /tmp/terraform.zip
rm -f /tmp/terraform.zip

# add additional non-standard plugins by extraction zips to .terrafrom..d 
#mkdir -p $HOME/.terraform.d
#curl https://path_to_plugin.zip | unzip -o -d $HOME/.terraform.d

# compile latest opentelekomcloud terraform provider
curl  https://storage.googleapis.com/golang/go1.10.3.linux-amd64.tar.gz > /tmp/go.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf /tmp/go.linux-amd64.tar.gz
mkdir /tmp/goprojects
export GOPATH=/tmp/goprojects
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

go get github.com/hashicorp/terraform
go get github.com/terraform-providers/terraform-provider-opentelekomcloud
cd /tmp/goprojects/src/github.com/terraform-providers/terraform-provider-opentelekomcloud
make build
mkdir -p /home/linux/.terraform.d/plugins/
cp /tmp/goprojects/bin/terraform-provider-opentelekomcloud /home/linux/.terraform.d/plugins/terraform-provider-opentelekomcloud_v100.0.0
rm -f /tmp/go.linux-amd64.tar.gz
rm -rf /tmp/goprojects

# install Chef server and DK
curl https://packages.chef.io/files/stable/chef-server/12.17.33/el/7/chef-server-core-12.17.33-1.el7.x86_64.rpm > /tmp/chef-server-core.rpm
sudo rpm -Uvh /tmp/chef-server-core.rpm
rm -f /tmp/chef-server-core.rpm 

curl https://packages.chef.io/files/stable/chefdk/3.2.30/el/7/chefdk-3.2.30-1.el7.x86_64.rpm > /tmp/chefdk.rpm
sudo rpm -Uvh /tmp/chefdk.rpm
rm -f /tmp/chefdk.rpm

# open chef port for the outside world of the server, leave protection
# to security group
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload

export JAVA_HOME="/usr/lib/jvm/jre-1.8.0"
echo "JAVA_HOME=\"/usr/lib/jvm/jre-1.8.0\" \
export JAVA_HOME" >> /home/linux/.bashrc_profile
