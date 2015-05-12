## Foreman-Puppet-Vagrant Multiple-VM Creation and Configuration
Automatically provision multiple VMs with Vagrant and VirtualBox. Automatically install, configure, and test
Foreman and Puppet Agents on those VMs.

## Vagrant Plugin
foreman-vagrant requires the vagrant-hostmanager plugin to be installed. You can install the plugin by running:

```sh
vagrant plugin install vagrant-hostmanager
```

The vagrant-vbguest addition plugin is also used to keep the tools updated.

```sh
vagrant plugin install vagrant-vbguest
```

#### JSON Configuration File
The `Vagrantfile` retrieves multiple VM configurations from a separate `nodes.json` JSON file. All VM configuration is
contained in that JSON file. You can add additional VMs to the JSON file, following the existing pattern. The
`Vagrantfile` will loop through all nodes (VMs) in the `nodes.json` file and create the VMs. You can easily swap
configuration files for alternate environments since the `Vagrantfile` is designed to be generic and portable.

### Host entries plugin
The `Vagrantfile` uses the `vagrant-hostmanager` plugin and makes sure that all entries are consistent between guests
and also the host itself. The plugin must be installed with `vagrant plugin install vagrant-hostmanager`.

#### Instructions
Suggest provisioning Foreman VM first, before agents. It will takes several minutes to create.
```sh
vagrant up theforeman.example.com
```
Important, when the provisioning is complete, note the results displayed once Foreman is installed!
They provide the admin login password and URL for the Foreman console.
```sh
==> theforeman.example.com:   Success!
==> theforeman.example.com:   * Foreman is running at https://theforeman.example.com
==> theforeman.example.com:       Initial credentials are admin / 7x2fpZBWgVEHvzTw
==> theforeman.example.com:   * Foreman Proxy is running at https://theforeman.example.com:8443
==> theforeman.example.com:   * Puppetmaster is running at port 8140
==> theforeman.example.com:   The full log is at /var/log/foreman-installer/foreman-installer.log
```
Log into the Foreman web-browser based console. Change the admin account password, and/or set-up your own admin account(s).

Next, build two puppet agent VMs.
```sh
vagrant up
```

```sh
# Shift+Ctrl+T # new tab on host
vagrant ssh agent01.example.com # ssh into agent node
# initiate certificate signing request (CSR)
sudo puppet agent --test --waitforcert=60
```

#### Forwarding Ports
Used by Vagrant and VirtualBox. To create additional forwarding ports, add them to the 'ports' array. For example:

 ```JSON
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

#### Errors
**Error: Unknown configuration section 'hostmanager'.**
=> **Solution: **Install the `vagrant-hostmanager` plugin with `vagrant plugin install vagrant-hostmanager`

#### Useful Multi-VM Commands
The use of the specific <machine> name is optional in most cases.
* `vagrant up <machine>`
* `vagrant reload <machine>`
* `vagrant destroy -f <machine> && vagrant up <machine>`
* `vagrant status <machine>`
* `vagrant ssh <machine>`
* `vagrant global-status`

#### Useful Logs for Debugging Project Issues
Some logs require sudo access
* `sudo tail -50 /var/log/syslog`
* `sudo tail -50 /var/log/puppet/masterhttp.log`
* `sudo tail -50 /var/log/foreman/production.log`
* `sudo tail -50 /var/log/foreman-installer/foreman-installer.log`
* `sudo tail -50 /var/log/foreman-proxy/proxy.log`
* `tail -50 ~/VirtualBox\ VMs/<group>/<machine>/Logs/VBox.log`
