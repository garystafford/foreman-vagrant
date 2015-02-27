#!/bin/sh

# Run on VM to bootstrap Foreman server
# Gary A. Stafford - 01/15/2015

if ps aux | grep "/usr/share/foreman" | grep -v grep 2> /dev/null
then
    echo "Foreman appears to all already be installed. Exiting..."
else

    # Update system first
    sudo yum update -y

    # Install Foreman for CentOS 6
    sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm && \
    sudo yum -y install epel-release http://yum.theforeman.org/releases/1.7/el6/x86_64/foreman-release.rpm && \
    sudo yum -y install foreman-installer && \
    sudo foreman-installer

    # First run the Puppet agent on the Foreman host which will send the first Puppet report to Foreman,
    # automatically creating the host in Foreman's database
    sudo puppet agent --test --waitforcert=60

    # Install some optional puppet modules on Foreman server to get started...
    sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-ntp
    sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-git
    sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-vcsrepo
    sudo puppet module install -i /etc/puppet/environments/production/modules garethr-docker
    sudo puppet module install -i /etc/puppet/environments/production/modules garystafford-fig
    sudo puppet module install -i /etc/puppet/environments/production/modules jfryman-nginx
    sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-haproxy
    sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-apache
    sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-java
fi
