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
export DEBIAN_FRONTEND=noninteractive

#!/bin/bash
# Update system
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove -y

# Install needed packages
apt-get install git wget snapd python3-pip -y

pip install -U pip
pip install pygit2

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
/tmp/install-salt.sh -n -M -L -A $(hostname -f) stable   # Also install salt-master
                                                            # Also install salt-cloud and required python-libcloud package
                                                            # Pass the salt-master DNS name or IP. This will be stored under ${BS_SALT_ETC_DIR}/minion.d/99-master-address.conf
apt-get install salt-api -y


# Clone git repo
#if [ -d "/srv/salt/base/.git" ]; then
#  echo "Repo is already here. Doing nothing..."
#else
#  git clone https://github.com/goINPUT-IT-Solutions/salt-hetzner /srv/salt/base
#fi

# Enable Reactor
cat <<EOT > /etc/salt/master.d/reactor.conf
reactor:
    - 'salt/auth':
        - salt://reactor/new_minion.sls
    - 'salt/engines/hook/hook/github':
        - /srv/salt/base/reactor/autodeploy.sls
        - salt://reactor/apply_state_all.sls
    - 'salt/minion/*/start':     
        - salt://reactor/apply_state.sls

EOT

# Enable Webhook
cat <<EOT > /etc/salt/master.d/webhook.conf
engines:
    - webhook:
        port: 9999
        ssl_crt: /etc/letsencrypt/live/$(hostname -f)/fullchain.pem
        ssl_key: /etc/letsencrypt/live/$(hostname -f)/privkey.pem

EOT

# Enable File Roots
cat <<EOT > /etc/salt/master.d/file_roots.conf
fileserver_backend:
    - roots
    - gitfs

gitfs_global_lock: False

gitfs_provider: pygit2
gitfs_update_interval: 60
gitfs_base: main

file_roots:
    base:
        - /srv/salt/public-key
    terraform: 
        - /srv/salt/terraform/states

gitfs_remotes:
    - https://github.com/goINPUT-IT-Solutions/salt-hetzner.git:   
        - name: git_states
        - root: states
        - mountpoint: salt://
    - https://github.com/goINPUT-IT-Solutions/salt-hetzner.git:   
        - name: git_reactor
        - root: reactor
        - mountpoint: salt://reactor
    - https://github.com/goINPUT-IT-Solutions/salt-hetzner.git:   
        - name: git_orchestrate
        - root: orchestrate
        - mountpoint: salt://orchestrate

ext_pillar:
    - git:
        # Use 'prod' instead of the branch name 'production' as the environment
        - main https://github.com/goINPUT-IT-Solutions/salt-hetzner.git:
            - env: base
            - root: pillar

pillar_roots:
    terraform: 
        - /srv/salt/terraform/pillar
EOT

# Enable Presence
cat <<EOT > /etc/salt/master.d/presence.conf
presence_events: True

EOT

# Enable Debug
cat <<EOT > /etc/salt/master.d/debug.conf
log_level: debug

EOT

# Restart Salt-Master
systemctl restart salt-master

sleep 10 # Wait 10 seconds to propagate