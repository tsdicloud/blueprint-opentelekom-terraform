#!/bin/bash

curl -L https://www.opscode.com/chef/install.sh | sudo bash
# -s -- -v ${var.chef_version}"
#  TODO: add knife ssl fetch my_chef_server_url to enable verified ssl/tls
#  TODO: and verify the fetched certs
