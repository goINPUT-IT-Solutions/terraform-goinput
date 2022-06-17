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
### Servers
##############################

/*output "server_ipv4" {
  value = [
    for server, value in module.servers : value.server_ipv4
  ]
  description = "IPv4 Address of Server"
}

output "server_ipv6" {
  value = [
    for server, value in module.servers : value.server_ipv6
  ]
  description = "IPv6 Address of Server"
}

output "server_name" {
  value = [
    for server, value in module.servers : value.server_ipv6
  ]
  description = "Hostname of Server"
}*/