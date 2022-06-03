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

output "saltstack_webservice_network_ip" {
  value = hcloud_server_network.saltbastion_webserive_network.ip
}

output "saltstack_public_ipv4" {
  value = hcloud_server.saltbastion.ipv4_address
}

output "saltstack_id" {
  value = hcloud_server.saltbastion.id
}

output "saltstack_public_ipv6" {
  value = hcloud_server.saltbastion.ipv6_address
}