#!/bin/bash
#
# Setup Image - Configure a packer-built image after initial Kickstart
#
# NOTE: This script is:
#   - run on the image being configured by packer (using the shell provisioner)
#
# ASSUMPTIONS: All content needed is dropped by a file provisioniner and placed
# into /tmp/packer for easy clean-up.
#

# Variables
#-------------------
PLATFORM_NAME=$(ohai platform | grep '"' | sed 's/[ "]//g')
case $PLATFORM_NAME in
  centos)
    OS_NAME="CentOS"
    ;;
  redhat)
    OS_NAME="RedHat"
    ;;
  *)
    OS_NAME="$PLATFORM_NAME"
    ;;
esac
OS_VERSION=$(ohai platform_version | grep '"' | sed 's/[ "]//g' | sed 's/\..*//')
LOG_BASE="/tmp/packer/${OS_NAME}-${OS_VERSION}"

# Functions
#-------------------
function run_cis {
  LEVEL=${1}

  CIS_INSPEC_REPO='cloudtrust-baseimage-inspec'
  LOG_FILE="${LOG_BASE}.cis_level${LEVEL}.log"

  echo "Seeing this message means no data was captured." >$LOG_FILE
  cd /tmp/packer/$CIS_INSPEC_REPO
  echo "${0}: Testing for CIS Level ${LEVEL} Benchmarking"
  sudo inspec exec cis-benchmark --attrs cis-benchmark/attributes/level${LEVEL}.yml >$LOG_FILE 2>&1
}

# MAIN
#-------------------
# >>> INSPEC <<<
run_cis 1
run_cis 2

# >>> GATHER INFORMATION <<<
# [Capture OHAI output]
LOG_FILE="${LOG_BASE}.ohai"

echo "Seeing this message means no data was captured." >$LOG_FILE
echo "${0}: Gathering OHAI information"
sudo ohai >$LOG_FILE 2>&1

# [Capture Installed RPMs]
LOG_FILE="${LOG_BASE}.rpm.list"

echo "Seeing this message means no data was captured." >$LOG_FILE
echo "${0}: Gathering RPM List"
rpm -qa | sort >$LOG_FILE 2>&1

# [Capture initramfs content]
echo ">>> Content of initramfs images <<<"
for image in $(ls /boot | grep "initramfs-" | grep -v rescue); do
  tag=$(echo ${image} | sed 's/\.img//')
  LOG_FILE="${LOG_BASE}.${tag}.content"
  echo "[[[ Content of ${image} ]]]" >$LOG_FILE
  sudo lsinitrd /boot/$image >>$LOG_FILE 2>&1
done

# [Capture Everything Else]
LOG_FILE="${LOG_BASE}.misc.info"

echo "Seeing this message means no data was captured." >$LOG_FILE
echo "${0}: Gathering Misc Information about Image"

echo ">>> Disk Space Utilization <<<" >$LOG_FILE
df -h >>$LOG_FILE 2>&1

echo "" >> $LOG_FILE

echo ">>> Module Information about Elastic Network Adapter (ENA) <<<" >>$LOG_FILE
sudo /sbin/modinfo ena >>$LOG_FILE 2>&1

# >>> CLEAN-UP <<<
echo "${0}: Collecting reports"
cd /tmp/packer
tar -czvf /tmp/reports.tgz ./${OS_NAME}-${OS_VERSION}.*
cd

echo "${0}: Removing provisioning content"
sudo rm -rf /tmp/packer*

exit 0
