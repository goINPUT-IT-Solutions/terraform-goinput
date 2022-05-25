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

variable "terraform_ssh_key_id" {
  type      = string
  sensitive = false
}

##############################
### Defaults
##############################

variable "server_count" {
  default   = 2
  type      = number
  sensitive = false
}

variable "service_name" {
  default   = "ns"
  type      = string
  sensitive = false
}

variable "domain" {
  type      = string
  sensitive = false
}