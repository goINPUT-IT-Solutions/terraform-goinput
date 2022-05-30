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

output "firewall_default_id" {
  value = hcloud_firewall.firewall_default.id
}

output "firewall_mailserver_id" {
  value = hcloud_firewall.firewall_mailserver.id
}

output "firewall_webservice_id" {
  value = hcloud_firewall.firewall_webservice.id
}

output "firewallsaltbastion_id" {
  value = hcloud_firewall.firewall_saltbastion.id
}

