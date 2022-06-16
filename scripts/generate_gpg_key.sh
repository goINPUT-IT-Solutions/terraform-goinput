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

#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

if [ ! -f "/etc/salt/gpgkeys/.done" ]; then
    if [ ! -d "/etc/salt/gpgkeys" ]; then
        mkdir -pv /etc/salt/gpgkeys
    fi

     if [ ! -d "/srv/salt" ]; then
        mkdir -pv /srv/salt
    fi

    apt-get install gnupg gnupg2 -y

    echo <<EOT > /etc/salt/gpgkeys/unattended-gpg-key
Key-Type: 1
Key-Length: 4096
Name-Real: ${salthost} (AUTOGEN)
Name-Email: saltadmin@goinput.de
Expire-Date: 0
EOT

    chmod 0700 /etc/salt/gpgkeys
    gpg --batch --generate-key --pinentry-mode=loopback --passphrase="" --homedir /etc/salt/gpgkeys /etc/salt/gpgkeys/unattended-gpg-key

    if [ ! -d "/srv/salt/public-key" ]; then
        mkdir -pv /srv/salt/public-key
    fi

    gpg --homedir /etc/salt/gpgkeys --armor --export > /srv/salt/public-key/key.gpg

    if [ ! -d "/srv/salt/private-key" ]; then
        mkdir -pv /srv/salt/private-key
    fi

    gpg --homedir /etc/salt/gpgkeys --export-secret-keys --armor > /srv/salt/private-key/key.gpg

    gpg --import /srv/salt/public-key/key.gpg

    echo "DONE" > /etc/salt/gpgkeys/.done
fi