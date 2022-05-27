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

variable "cloudflare_email" {
  type      = string
  sensitive = false
}

variable "cloudflare_api_key" {
  type      = string
  sensitive = true
}

##############################
### Hetzner
##############################

variable "hcloud_token" {
  type      = string
  sensitive = true
}

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

##############################
### Bitwarden
##############################

variable "bitwarden_master_password" {
  type      = string
  sensitive = true
}

variable "bitwarden_client_id" {
  type      = string
  sensitive = true
}

variable "bitwarden_client_secret" {
  type      = string
  sensitive = true
}

variable "bitwarden_email" {
  type      = string
  sensitive = false
}

variable "bitwarden_server" {
  type      = string
  sensitive = false
}

##############################
### Defaults
##############################

variable "terraform_ssh_key" {
  type      = string
  sensitive = false
}

variable "domain" {
  default   = "goitservers.com"
  type      = string
  sensitive = false
}