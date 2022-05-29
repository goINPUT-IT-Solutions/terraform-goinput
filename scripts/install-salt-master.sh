#!/bin/bash

# Install needed packages
apt-get install git wget

# Get Salt Bootstrap
wget -O /tmp/install-salt.sh https://bootstrap.saltstack.com

# Make installer executable
chmod +x /tmp/install-salt.sh

# Install salt
/tmp/install-salt.sh    -M \        # Also install salt-master
                        -L \        # Also install salt-cloud and required python-libcloud package
                        -A main     # Pass the salt-master DNS name or IP. This will be stored under ${BS_SALT_ETC_DIR}/minion.d/99-master-address.conf


