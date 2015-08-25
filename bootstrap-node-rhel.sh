#!/bin/sh

# Run on VM to bootstrap the Puppet Agent RHEL-based Linux nodes
# Gary A. Stafford - 01/15/2015
# Modified - 08/19/2015
# Downgrade Puppet on box from 4.x to 3.x for Foreman 1.9 
# http://theforeman.org/manuals/1.9/index.html#3.1.2PuppetCompatibility

# Update system first
sudo yum update -y

if puppet agent --version | grep "3." | grep -v grep 2> /dev/null
then
    echo "Puppet Agent $(puppet agent --version) is already installed. Moving on..."
else
    echo "Puppet Agent $(puppet agent --version) installed. Replacing..."
    
    sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm && \
    sudo yum -y erase puppet-agent && \
    sudo rm -f /etc/yum.repos.d/puppetlabs-pc1.repo && \
    sudo yum clean all && \
    sudo yum -y install puppet nano nmap-ncat

    # Add agent section to /etc/puppet/puppet.conf
    # Easier to set run interval to 120s for testing (reset to 30m for normal use)
    # https://docs.puppetlabs.com/puppet/3.8/reference/config_about_settings.html
    echo "" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
    echo "    server = theforeman.example.com" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
    echo "    runinterval = 120s" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null

    sudo service puppet stop
    #sudo service puppet start
    sudo puppet resource service puppet ensure=running enable=true
    sudo puppet agent --enable

    # Unless you have Foreman autosign certs, each agent will hang on this step until you manually
    # sign each cert in the Foreman UI (Infrastrucutre -> Smart Proxies -> Certificates -> Sign)
    # Alternative, run manually on each host, after provisioning is complete...
    #sudo puppet agent --test --waitforcert=60
fi