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
### Cloudflare
##############################

variable "dns_zone" {
  type      = string
  sensitive = false
}

##############################
### Default
##############################

variable "srv_count" {
  type      = number
  sensitive = false
}

##############################
### Domain
##############################

variable "domain_name" {
  type      = string
  sensitive = false
}

variable "domain_ipv4" {
  type      = string
  sensitive = false
}

variable "domain_ipv6" {
  type      = string
  sensitive = false
}

variable "domain_ttl" {
  type      = number
  sensitive = false
}