#!/bin/bash

# Install needed packages
apt-get install git wget

# Get Salt Bootstrap
wget -O /tmp/install-salt.sh https://bootstrap.saltstack.com

# Make installer executable
chmod +x /tmp/install-salt.sh

# Install salt
/tmp/install-salt.sh -M -L -A main  # Also install salt-master
                                    # Also install salt-cloud and required python-libcloud package
                                    # Pass the salt-master DNS name or IP. This will be stored under ${BS_SALT_ETC_DIR}/minion.d/99-master-address.conf


# Clone git repo
git clone https://github.com/goINPUT-IT-Solutions/salt-hetzner /srv/salt

# Enable Reactor
cat <<EOT > /etc/salt/master.d/reactor.conf
reactor:
    - 'salt/auth':
    - /srv/salt/reactor/auth-pending.sls
EOT

# Restart Salt-Master
systemctl restart salt-master