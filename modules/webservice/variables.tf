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

variable "network_id" {
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
### Cloudflare
##############################

variable "dns_zone" {
  type      = string
  sensitive = false
}

variable "cloudflare_email" {
  type      = string
  sensitive = false
}

variable "cloudflare_api_key" {
  type      = string
  sensitive = true
}

##############################
### Server counts
##############################

variable "apache_count" {
  default   = 1
  type      = number
  sensitive = false
}

variable "nextcloud_count" {
  default   = 1
  type      = number
  sensitive = false
}

variable "jitsi_count" {
  default   = 1
  type      = number
  sensitive = false
}

variable "wireguard_count" {
  default   = 1
  type      = number
  sensitive = false
}

variable "bitwarden_count" {
  default   = 1
  type      = number
  sensitive = false
}

##############################
### Saltmaster
##############################

variable "saltmaster_id" {
  type      = string
  sensitive = false
}

variable "saltmaster_public_ip" {
  type      = string
  sensitive = false
}

variable "saltmaster_ip" {
  type      = string
  sensitive = false
}

##############################
### SSH
##############################

variable "ssh_key" {
  type      = list(number)
  sensitive = false
}

variable "private_key" {
  type      = string
  sensitive = true
}

##############################
### Let's Encrypt
##############################

variable "acme_account_key" {
  type      = string
  sensitive = true
}

variable "goinput_certificate_id" {
  type      = string
  sensitive = false
}
