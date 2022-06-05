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

output "server_ipv4" {
  value = {
      "${var.server_name}" = [for server in hcloud_server.webservice_server : server.ipv4_address]
  }
  description = "IPv4 Address of Server"
}

output "server_ipv6" {
  value = {
      "${var.server_name}" = [for server in hcloud_server.webservice_server : server.ipv6_address]
  }
  description = "IPv6 Address of Server"
}

output "server_name" {
  value = {
      "${var.server_name}" = [for server in hcloud_server.webservice_server : server.name]
  }
  description = "Hostname of Server"
}
