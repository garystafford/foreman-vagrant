#!/bin/sh

# Run on VM to bootstrap Puppet Agent Ubuntu-based Linux nodes
# Gary A. Stafford - 02/27/2015
# *** Needs to be fixed like other scripts to avoid Puppet 4.x!!!

if ps aux | grep "puppet agent" | grep -v grep 2> /dev/null
then
    echo "Puppet Agent is already installed. Moving on..."
else
    sudo apt-get install -yq puppet
fi

if cat /etc/crontab | grep puppet 2> /dev/null
then
    echo "Puppet Agent is already configured. Exiting..."
else
    # Update system first
    sudo apt-get update -yq && sudo apt-get upgrade -yq

    # Add puppet agent cron job
    sudo puppet resource cron puppet-agent ensure=present user=root minute=30 \
        command='/usr/bin/puppet agent --onetime --no-daemonize --splay'

    sudo puppet resource service puppet ensure=running enable=true

    # Add agent section to /etc/puppet/puppet.conf (sets run interval to 120 seconds)
    echo "" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
    echo "[agent]" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
    echo "server=theforeman.example.com" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
    echo "runinterval=30m" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null

    sudo service puppet stop
    sudo service puppet start

    sudo puppet resource service puppet ensure=running enable=true
    sudo puppet agent --enable

    # Unless you have Foreman autosign certs, each agent will hang on this step until you manually
    # sign each cert in the Foreman UI (Infrastrucutre -> Smart Proxies -> Certificates -> Sign)
    # alternative, run manually on each host, after provisioning is complete...
    #sudo puppet agent --test --waitforcert=60
fi
