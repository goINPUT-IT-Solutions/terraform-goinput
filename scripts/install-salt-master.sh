######################################################
#               _____ _   _ _____  _    _ _______    #
#              |_   _| \ | |  __ \| |  | |__   __|   #
#     __ _  ___  | | |  \| | |__) | |  | |  | |      #
#    / _` |/ _ \ | | | . ` |  ___/| |  | |  | |      #
#   | (_| | (_) || |_| |\  | |    | |__| |  | |      #
#    \__, |\___/_____|_| \_|_|     \____/   |_|      #
#     __/ |                                          #
#    |___/                                           #
#                                                    #
######################################################

# File: install-salt-master.sh

#!/bin/bash
# Update system
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove -y

# Install needed packages
apt-get install git wget snapd -y

# Install certbot (ufff snap)
snap install certbot --classic
snap set certbot trust-plugin-with-root=ok
snap install certbot-dns-cloudflare --classic

# Optain certificate
chmod 600 /root/cloudflare.ini
certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/cloudflare.ini --dns-cloudflare-propagation-seconds 60 --non-interactive --agree-tos -m admin@goinput.de -d $(hostname -f)

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
file_roots:
    base:
        - /srv/salt

reactor:
    - 'salt/auth':
        - salt://reactor/new_minion.sls
    - 'salt/engines/hook/github':
        - salt://reactor/autodeploy.sls
EOT

# Enable Webhook
cat <<EOT > /etc/salt/master.d/webhook.conf
engines:
    - webhook:
        port: 9999
        ssl_crt: /etc/letsencrypt/live/$(hostname -f)/fullchain.pem
        ssl_key: /etc/letsencrypt/live/$(hostname -f)/privkey.pem
EOT

# Restart Salt-Master
systemctl restart salt-master

sleep 10 # Wait 10 seconds to propagate