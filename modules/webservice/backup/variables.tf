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

variable "terraform_private_ssh_key_id" {
  type      = string
  sensitive = false
}

variable "terraform_private_ssh_key" {
  type      = string
  sensitive = true
}

variable "network_webservice_id" {
  type      = string
  sensitive = false
}

variable "firewall_default_id" {
  type      = string
  sensitive = false
}

variable "firewall_webservice_id" {
  type      = string
  sensitive = false
}

##############################
### Defaults
##############################

variable "environment" {
  type      = string
  sensitive = false
}

variable "domain" {
  type      = string
  sensitive = false
}

##############################
### Saltstack
##############################

variable "saltmaster_ip" {
  type      = string
  sensitive = false
}

variable "saltmaster_public_ip" {
  type      = string
  sensitive = false
}

##############################
### Cloudflare
##############################

variable "dns_zone" {
  type      = string
  sensitive = false
}

##############################
### Server-Count
##############################

variable "apache_count" {
  default   = 1
  type      = number
  sensitive = false
}

variable "jitsi_count" {
  default   = 1
  type      = number
  sensitive = false
}

variable "nextcloud_count" {
  default   = 1
  type      = number
  sensitive = false
}

variable "wireguard_count" {
  default   = 1
  type      = number
  sensitive = false
}
