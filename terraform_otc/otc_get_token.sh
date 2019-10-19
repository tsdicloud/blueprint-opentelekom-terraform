#!/bin/bash

otc_region="eu_"
otc_domain=""
otc_password=""
otc_user=""
otc_project=""
otc_cacert="../otc_certs.pem"
otc_auth_url=""
otc_api_version=""

# set -x

while (( "$#" )); do
    case $1 in
        --os-region-name ) shift
                        otc_region="$1"
                        otc_auth_url="https://iam.${otc_region}.otc.t-systems.com/v3"
                        ;;
        --os-username ) shift
                        otc_user="$1"
                        ;;
        --os-password ) shift
                        otc_password="$1"
                        ;;
        --os-domain-name ) shift
                        otc_tenant="$1"
                        ;;
        --os-project-name ) shift
                        otc_project="$1"
                        ;;
        --os-cacert ) shift
                        otc_cacert="$1"
                        ;;
        --os-auth-url ) shift
                        otc_auth_url="$1"
                        ;;
        --os-identity-api-version ) shift
                        otc_api_version="$1"
                        ;;
        * )             shift
                        ;; 
    esac
    shift
done


os_access="--os-region-name ${otc_region} --os-username ${otc_user} --os-password ${otc_password} --os-domain-name ${otc_tenant} --os-project-name ${otc_project} --os-cacert ${otc_cacert} --os-identity-api-version ${otc_api_version} --os-auth-url ${otc_auth_url}"

openstack token issue -f json $os_access | jq '{ value: .id }'
