#!/bin/bash

# Disable Floppy Driver
sudo echo 'blacklist floppy' | sudo tee /etc/modprobe.d/nofloppy.conf

for ramdisk in $(ls -1 /boot | grep initramfs-); do
  version=$(echo $ramdisk | sed 's/initramfs-//' | sed 's/\.img//')
  if [ -z "$(echo $ramdisk | grep rescue)" ]; then
    echo "Rebuilding /boot/${ramdisk}"
    sudo dracut --add-drivers "hv_storvsc hv_vmbus udf" -f $ramdisk
    #sudo dracut --omit-drivers "xen-scsifront" -f $ramdisk
  fi
done
