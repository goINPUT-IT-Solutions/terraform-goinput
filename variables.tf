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
### Let's Encrypt
##############################

variable "acme_server_url" {
  type      = string
  sensitive = false
  default   = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "acme_email" {
  type      = string
  sensitive = false
  default   = "admin@goinput.de"
}

##############################
### GitHub
##############################

variable "github_token" {
  type      = string
  sensitive = false
}

##############################
### Defaults
##############################

variable "domain" {
  default   = "goitservers.com"
  type      = string
  sensitive = false
}

variable "environment" {
  type      = string
  sensitive = false
}

variable "domains" {
  type      = set(string)
  sensitive = false
}