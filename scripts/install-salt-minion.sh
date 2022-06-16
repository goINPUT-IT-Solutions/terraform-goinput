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

echo nameserver 8.8.8.8 > /etc/resolv.conf

echo -e  'y\n'| ssh-keygen -b 4096 -t rsa -P '' -f /root/.ssh/id_rsa -q
wget -O /tmp/bootstrap-salt.sh https://bootstrap.saltstack.com
sh /tmp/bootstrap-salt.sh -n -L -A ${saltmasterIP} stable

echo '${serverName}' > /etc/salt/minion_id


cat <<EOT > /etc/salt/minion.d/new_module_run.conf
use_superseded:
    - module.run
EOT

systemctl restart salt-minion
systemctl enable salt-minion