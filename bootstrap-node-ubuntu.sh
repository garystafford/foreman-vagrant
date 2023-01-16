#!/bin/sh

# Run on VM to bootstrap Puppet Agent Ubuntu-based Linux nodes
# Gary A. Stafford - 02/27/2015
# Modified to use Puppet 7.x - 01/17/2023

if ps aux | grep "puppet agent" | grep -v grep 2> /dev/null
then
    echo "Puppet Agent is already installed. Moving on..."
else
    wget https://apt.puppetlabs.com/puppet7-release-$(lsb_release -cs).deb
    sudo dpkg -i puppet7-release-$(lsb_release -cs).deb
    sudo apt-get update -yq
    sudo apt-get install -yq puppet-agent
    sudo ln -s /opt/puppetlabs/bin/puppet /usr/sbin/puppet
fi

if cat /etc/crontab | grep puppet 2> /dev/null
then
    echo "Puppet Agent is already configured. Exiting..."
else
    # Update system first (commented to speed up the deployment)
    #sudo apt-get update -yq && sudo apt-get upgrade -yq

    # Add puppet agent cron job
    sudo puppet resource cron puppet-agent ensure=present user=root minute=30 \
        command='/usr/bin/puppet agent --onetime --no-daemonize --splay'

    sudo puppet resource service puppet ensure=running enable=true

    # Add agent section to /etc/puppetlabs/puppet/puppet.conf (set run interval to 120s for testing)
    echo "" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
    echo "[agent]" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
    echo "server=theforeman.example.com" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
    echo "runinterval=30m" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null

    sudo service puppet stop
    #sudo service puppet start

    sudo puppet resource service puppet ensure=running enable=true
    sudo puppet agent --enable

    # Unless you have Foreman autosign certs, each agent will hang on this step until you manually
    # sign each cert in the Foreman UI (Infrastrucutre -> Smart Proxies -> Certificates -> Sign)
    # Aternative, run manually on each host, after provisioning is complete...
    #sudo puppet agent --test --waitforcert=60
fi
