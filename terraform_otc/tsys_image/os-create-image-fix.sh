#!/bin/bash

SERVER_ID=$1
VOLUME_ID=$2
IMAGE="$3"
AUTH_URL=$4
ACCESS=${@:5}

#set -x

# cleanu all old images with the same name
openstack image delete "${IMAGE}" --os-auth-url "${AUTH_URL}" $ACCESS

# stop server
openstack server stop $SERVER_ID --os-auth-url "${AUTH_URL}" $ACCESS
status=""
while [ "$status" != "SHUTOFF" ]; do
  eval `openstack server show --os-auth-url "${AUTH_URL}" $ACCESS -f shell $SERVER_ID`
  sleep 5
done


# cinder only accepts image upload from detached volumes
openstack server remove volume $SERVER_ID $VOLUME_ID --os-auth-url "${AUTH_URL}" $ACCESS
status=""
while [ "$status" != "available" ]; do
  eval `openstack volume show --os-auth-url "${AUTH_URL}" $ACCESS -f shell $VOLUME_ID`
  sleep 5
done

# upload image from volume with keystone token authentication (tricky move)
eval `openstack token issue -f shell --os-auth-url "${AUTH_URL}" $ACCESS`
image_id=`cinder --os-auth-type "token" --os-project-id="$project_id"  --os-token "${id}" --os-auth-url "${AUTH_URL}" --os-volume-api-version 2 upload-to-image $VOLUME_ID "$IMAGE" --disk-format "zvhd2" | grep -owP "image_id.*\|\s\K.*[^\|]+"`
# add tags while 
if [ "$image_id" != "" ]; then
  # wait for image to get available
  status=""
  while [ "$status" != "active" ]; do
    eval `openstack image show --os-auth-url "${AUTH_URL}" $ACCESS -f shell $image_id`
    sleep 5
  done
  openstack image set --tag AMIID.BASEAMIRHEL7 $image_id --os-auth-url "${AUTH_URL}" $ACCESS
fi

# we do not wait for server and volume to delete because this is the
# last step and no dependent commands follow
openstack server delete $SERVER_ID --os-auth-url "${AUTH_URL}" $ACCESS
openstack volume delete $VOLUME_ID --os-auth-url "${AUTH_URL}" $ACCESS
