#!/bin/sh

# Fixes Vagrant error - "vboxsf" file system is not available
# Due to yum update of kernal on chef/centos-6.5 box
# Restart boxes (vagrant reload), apply commands below, restart again...
# Gary A. Stafford - 01/15/2015

# provisioning script lalready ran with vagrant up
# vagrant reload agent01.example.com
# scp fix_vboxsf_error.sh vagrant@agent01.example.com:~/
# vagrant ssh agent01.example.com
# sh fix_vboxsf_error.sh
# exit
# vagrant reload agent01.example.com

if ! mount | grep "vboxsf" | grep -v grep 2> /dev/null
then
    target_kernel="2.6.32-504.3.3.el6.x86_64"
    current_kernel="$(uname -r)"
    echo $current_kernel

if [ $current_kernel == $target_kernel ]
then
        sudo yum -y install gcc perl
        sudo yum -y install kernel-devel-2.6.32-504.3.3.el6.x86_64 && \
        sudo /etc/init.d/vboxadd setup
    else
        echo "Kernels don't match. Update above script to current kernel."
    fi
fi