#!/bin/sh

# Run on VM to bootstrap Puppet Agent nodes

if ps aux | grep "puppet agent" | grep -v grep 2> /dev/null
then
    echo "Puppet Agent is already installed. Moving on..."
else
    # Update system first
    sudo yum update -y

    # fix Vagrant error - "vboxsf" file system is not available
    # due to yum update of kernal - 1x fix....
    #sudo yum -y install kernel-devel-2.6.32-504.3.3.el6.x86_64 && \
    #sudo yum -y install gcc && \
    #sudo /etc/init.d/vboxadd setup

    sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm && \
    sudo yum -y install puppet

    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.35.5    theforeman.example.com   theforeman" | sudo tee --append /etc/hosts 2> /dev/null

    # Add agent section to /etc/puppet/puppet.conf
    echo "" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
    echo "    server = theforeman.example.com" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
    echo "    runinterval = 2m" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null

    sudo puppet resource service puppet ensure=running enable=true

    sudo puppet agent --enable

    sudo puppet agent --test --waitforcert=60
fi