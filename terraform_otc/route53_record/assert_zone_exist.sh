#!/bin/bash

otc_tmoken=""
otc_region=""
type="private"
zone=""
vpc=""

while (( "$#" )); do
    case $1 in
        --os-token ) shift
                        otc_token="$1"
                        ;;
        --os-region ) shift
                        otc_region="$1"
                        ;;
        --type ) shift
                        type="$1"
                        ;;
        --zone ) shift
                        zone="$1."
                        ;;
        --vpc ) shift
                        otc_vpc="$1"
                        ;;
        * )             shift
                        ;; 
    esac
    shift
done

#set -x

id=""
if [ type == "private" ]; then
  id=`curl --silent --header "X-Auth-Token: $otc_token" https://dns.${otc_region}.otc.t-systems.com/v2/zones?type=${type}| jq --arg zone "${zone}" --arg vpc "${otc_vpc}" ".zones[]|select(.name==\"$zone\")|select(.routers[]|.router_id==\"$otc_vpc\")|.id"`
else
  id=`curl --silent --header "X-Auth-Token: $otc_token" https://dns.${otc_region}.otc.t-systems.com/v2/zones?type=${type}| jq --arg zone "${zone}" --arg vpc "${otc_vpc}" ".zones[]|select(.name==\"$zone\")|.id"`
fi

#
# only create zones if they not exist, never delete
#
if [ -z $id ]; then
  id=`curl --silent -X POST --header "X-Auth-Token: $otc_token" --header "Content-Type: application/json" --data \
    '{ "name": "'${zone}'", "zone_type": "'${type}'", "router": { "router_region": "'${otc_region}'", "router_id": "'${otc_vpc}'" } }' \
     https://dns.${otc_region}.otc.t-systems.com/v2/zones | jq ".id"`
fi

echo "{ \"id\": "${id}" }"
