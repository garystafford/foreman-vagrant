#!/bin/sh

# Run on VM to bootstrap Puppet Agent Ubuntu-based Linux nodes
# Gary A. Stafford - 02/27/2015

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
    sudo apt-get update -yq
    # Fix Grub prompt asking config to use.
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade

    # Add puppet agent cron job
    sudo /opt/puppetlabs/bin/puppet resource cron puppet-agent ensure=present user=root minute=30 \
        command='/opt/puppetlabs/bin/puppet agent --onetime --no-daemonize --splay'

    sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true

    # Add agent section to /etc/puppet/puppet.conf (set run interval to 120s for testing)
    echo "" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
    echo "[agent]" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
    echo "server=theforeman.example.com" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
    echo "runinterval=30m" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null

    sudo service puppet stop
    #sudo service puppet start

    sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
    sudo /opt/puppetlabs/bin/puppet agent --enable

    # Unless you have Foreman autosign certs, each agent will hang on this step until you manually
    # sign each cert in the Foreman UI (Infrastrucutre -> Smart Proxies -> Certificates -> Sign)
    # Aternative, run manually on each host, after provisioning is complete...
    #sudo puppet agent --test --waitforcert=60
fi
