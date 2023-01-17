#!/bin/sh

# Run on VM to bootstrap the Foreman server
# Gary A. Stafford - 01/15/2015
# Modified - 08/19/2015
# Downgrade Puppet on box from 4.x to 3.x for Foreman 1.9 
# http://theforeman.org/manuals/1.9/index.html#3.1.2PuppetCompatibility

#ID=$(cat /etc/os-release | awk -F= '/^ID=/{print $2}' | tr -d '"')
VERS=$(cat /etc/os-release | awk -F= '/^VERSION_ID=/{print $2}' | tr -d '"' |cut -d \. -f1)

# Update system first (commented to speed up the deployment)
#sudo yum update -y

if puppet agent --version | grep "7." | grep -v grep 2> /dev/null
then
    echo "Puppet Agent $(puppet agent --version) is already installed. Moving on..."
else
    echo "Puppet Agent $(puppet agent --version) installed. Replacing..."

    sudo rpm -Uvh https://yum.puppet.com/puppet7-release-el-${VERS}.noarch.rpm && \
    sudo yum remove puppet-agent -y && \
    sudo rm -f /etc/yum.repos.d/puppetlabs-pc1.repo && \
    sudo yum clean all && \
    sudo yum -y install puppet
    sudo ln -s /opt/puppetlabs/bin/puppet /usr/sbin/puppet
fi

if ps aux | grep "/usr/share/foreman" | grep -v grep 2> /dev/null
then
    echo "Foreman appears to all already be installed. Exiting..."
else
    #get rid off an issue with the foreman-installer related to DNS
    sudo sed -i "s/127.0.1.1/#127.0.1.1/g" /etc/hosts 

    sudo yum -y install epel-release http://yum.theforeman.org/releases/3.5/el${VERS}/x86_64/foreman-release.rpm && \
    sudo dnf module reset postgresql ruby foreman -y && \
    sudo dnf module enable ruby:2.7 postgresql:12 foreman:el8 -y && \
    sudo yum -y install foreman-installer nano nmap-ncat && \
    sudo foreman-installer

    sudo systemctl start firewalld

    # Set-up firewall
    # https://www.digitalocean.com/community/tutorials/additional-recommended-steps-for-new-centos-7-servers
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --permanent --add-port=69/tcp
    sudo firewall-cmd --permanent --add-port=67-69/udp
    sudo firewall-cmd --permanent --add-port=53/tcp
    sudo firewall-cmd --permanent --add-port=53/udp
    sudo firewall-cmd --permanent --add-port=8443/tcp
    sudo firewall-cmd --permanent --add-port=8140/tcp

    sudo firewall-cmd --reload
    sudo systemctl enable firewalld

    # First run the Puppet agent on the Foreman host which will send the first Puppet report to Foreman,
    # automatically creating the host in Foreman's database
    sudo puppet agent --test --waitforcert=60

    # Optional, install some optional puppet modules on Foreman server to get started...
    sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-ntp
    sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-git
    sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-vcsrepo
    sudo puppet module install -i /etc/puppet/environments/production/modules garethr-docker
    sudo puppet module install -i /etc/puppet/environments/production/modules jfryman-nginx
    sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-haproxy
    sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-apache
    sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-java
fi