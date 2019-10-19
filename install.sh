#!/bin/basg

sudo yum -y update --skip-broken && sudo yum -y upgrade --skip-broken

# enable TCP forwarding and kernel setup for VSCode Remote Development
sudo sed -i 's/^.*AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
sudo -- bash -c "grep -q  'fs.inotify.max_user_watches' /etc/sysctl.conf && 
       sed -i 's/.*fs.inotify.max_user_watches.*/fs.inotify.max_user_watches=524288/' /etc/sysctl.conf || 
       echo 'fs.inotify.max_user_watches=524288' >> /etc/sysctl.conf"
sudo sysctl -p

# prerequisites are sudo privileges, unzip, make, wget and git.  Use apt install if missing.
sudo yum -y install python3 unzip make curl wget git --skip-broken

# Install GO on /ust/local
curl https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz | sudo tar -C /usr/local -xz
if [ ! -f "/etc/profile.d/go.sh" && -f "/usr/local/go/bin/go" ];
then
    sudo bash -c "echo 'export PATH=/usr/local/go/bin:\$PATH' >> /etc/profile.d/go.sh"
fi

# install terraform
curl https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_linux_amd64.zip > /tmp/tf.zip; \
    sudo unzip /tmp/tf.zip -d /usr/local/go/bin; rm -f /tmp/tf.zip

# install the opentelekom cloud plugin (individually for each user)
go get github.com/terraform-providers/terraform-provider-opentelekomcloud
cd ~/go/src/github.com/terraform-providers/terraform-provider-opentelekomcloud/
make build

# install sdk and commandline client
sudo yum -y install python3
sudo python3 -m ensurepip
sudo rm -f /usr/bin/pip3
sudo ln -s /usr/local/bin/pip3 /usr/bin/pip3
sudo pip3 install --upgrade pip setuptools

# we want to have opentelekomsdk extensions which automatically pulls
# a proper openstacksdk version as dependency
pushd /tmp
# make script more stable by preventive cleanup before clone
sudo rm -rf python-opentelekom-sdk
git clone https://github.com/tsdicloud/python-opentelekom-sdk
pushd python-opentelekom-sdk
sudo pip3 install -r requirements.txt
sudo python3 setup.py install 
popd
sudo rm -rf python-opentelekom-sdk
popd

terraform init
terraform providers
