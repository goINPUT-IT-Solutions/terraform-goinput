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
### Hetzner
##############################

variable "nameserver_network_name" {
  type      = string
  sensitive = false
}

variable "nameserver_network_ip_range" {
  type      = string
  sensitive = false
}

variable "mailserver_network_name" {
  type      = string
  sensitive = false
}

variable "mailserver_network_ip_range" {
  type      = string
  sensitive = false
}

variable "webservice_network_name" {
  type      = string
  sensitive = false
}

variable "webservice_network_ip_range" {
  type      = string
  sensitive = false
}

