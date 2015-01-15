## Vagrant Multiple-VM Creation and Configuration
Automatically provision multiple VMs with Vagrant and VirtualBox. Automatically install, configure, and test
Foreman and Puppet Agents on those VMs. All instructions can be found in my blog post:
[TBD](TBD)


#### JSON Configuration File
The Vagrantfile retrieves multiple VM configurations from a separate `nodes.json` file. All VM configuration is
contained in the JSON file. You can add additional VMs to the JSON file, following the existing pattern. The
Vagrantfile will loop through all nodes (VMs) in the `nodes.json` file and create the VMs. You can easily swap
configuration files for alternate environments since the Vagrantfile is designed to be generic and portable.

#### Instructions
```
vagrant up # brings up all VMs
vagrant ssh theforeman.example.com

# Shift+Ctrl+T # new tab on host
vagrant ssh agent01.example.com # ssh into agent node
sudo service puppet status # test that agent was installed
# initiate certificate signing request (CSR)
sudo puppet agent --test --waitforcert=60
```

#### Forwarding Ports
Used by Vagrant and VirtualBox. To create additional forwarding ports, add them to the 'ports' array. For example:
 ```
 "ports": [
        {
          ":host": 1234,
          ":guest": 2234,
          ":id": "port-1"
        },
        {
          ":host": 5678,
          ":guest": 6789,
          ":id": "port-2"
        }
      ]
```
#### Useful Multi-VM Commands
The use of the specific <machine> name is optional.
* `vagrant up <machine>`
* `vagrant reload <machine>`
* `vagrant destroy -f <machine> && vagrant up <machine>`
* `vagrant status <machine>`
* `vagrant ssh <machine>`
* `vagrant global-status`
* `facter`
* `sudo tail -50 /var/log/syslog`
* `sudo tail -50 /var/log/puppet/masterhttp.log`
* `tail -50 ~/VirtualBox\ VMs/postblog/<machine>/Logs/VBox.log'