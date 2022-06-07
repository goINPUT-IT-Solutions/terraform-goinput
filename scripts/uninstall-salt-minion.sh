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

# Remove and purge packages
apt-get remove --purge salt-* -y
apt-get autoremove -y
apt-get autoclean -y

# Remove directory
if [ -d "/etc/salt " ]; then
  rm -rf /etc/salt 
fi

if [ -d "/srv/salt " ]; then
  rm -rf /srv/salt 
fi
