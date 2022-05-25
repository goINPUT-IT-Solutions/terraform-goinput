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

##############################
### Network: Nameserver
##############################

output "nameserver_network_id" {
  description = "Id of Nameserver Network"
  value       = hcloud_network.hcloud_network_nameserver.id
}

output "nameserver_network_name" {
  description = "Name of Nameserver Network"
  value       = hcloud_network.hcloud_network_nameserver.name
}

output "nameserver_network_ip_range" {
  description = "IP Range of Nameserver Network"
  value       = hcloud_network.hcloud_network_nameserver.ip_range
}

output "nameserver_network_labels" {
  description = "Labels of Nameserver Network"
  value       = hcloud_network.hcloud_network_nameserver.labels
}

##############################
### Network: Webservice
##############################

output "webservice_network_id" {
  description = "Id of Webservice Network"
  value       = hcloud_network.hcloud_network_webservice.id
}

output "webservice_network_name" {
  description = "Name of Webservice Network"
  value       = hcloud_network.hcloud_network_webservice.name
}

output "webservice_network_ip_range" {
  description = "IP Range of Webservice Network"
  value       = hcloud_network.hcloud_network_webservice.ip_range
}

output "webservice_network_labels" {
  description = "Labels of Webservice Network"
  value       = hcloud_network.hcloud_network_webservice.labels
}
