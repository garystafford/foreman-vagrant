#!/bin/sh

# Run on VM to bootstrap Puppet Agent RHEL-based Linux nodes
# Gary A. Stafford - 01/15/2015
# Modified - 08/19/2015

if ps aux | grep "puppet agent" | grep -v grep 2> /dev/null
then
    echo "Puppet Agent is already installed. Moving on..."
else
    # Update system first
    yum update -y

    # Downgrade Puppet from 4.x to 3.8.2 on CentOS 7 
    # (older version required for Foreman)
    sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm && \
    sudo yum -y erase puppet-agent && \
    sudo rm -f /etc/yum.repos.d/puppetlabs-pc1.repo && \
    sudo yum clean all && \
    sudo yum -y install puppet
    echo sudo puppet --version

    # Add agent section to /etc/puppet/puppet.conf (set run interval to 120s for testing)
    # https://docs.puppetlabs.com/puppet/3.8/reference/config_about_settings.html
    echo "" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
    echo "    server = theforeman.example.com" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
    echo "    runinterval = 30m" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null

    sudo service puppet stop
    sleep 3
    sudo service puppet start
    sleep 3
    puppet resource service puppet ensure=running enable=true
    puppet agent --enable

    # Unless you have Foreman autosign certs, each agent will hang on this step until you manually
    # sign each cert in the Foreman UI (Infrastrucutre -> Smart Proxies -> Certificates -> Sign)
    # Alternative, run manually on each host, after provisioning is complete...
    #sudo puppet agent --test --waitforcert=60
fi