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

##############################
### Servers
##############################

variable "server_name" {
  type      = string
  sensitive = false
}
variable "server_count" {
  type      = number
  sensitive = false
}

variable "server_type" {
  type      = string
  sensitive = false
}

variable "server_backup" {
  type      = bool
  sensitive = false
}

variable "server_image" {
  type      = string
  sensitive = false
}

variable "server_labels" {
  type      = map(string)
  sensitive = false
}

variable "network_id" {
  type      = string
  sensitive = false
}

##############################
### Loadbalancer
##############################

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
### Loadbalancer
##############################

variable "loadbalancer_proxyprotocol" {
  type      = bool
  sensitive = false
}

variable "loadbalancer_protocol" {
  type      = string
  sensitive = false
}

variable "loadbalancer_destination_port" {
  type      = number
  sensitive = false
}

variable "loadbalancer_listen_port" {
  type      = number
  sensitive = false
}

##############################
### LB: Health Check
##############################

variable "loadbalancer_hc_protocol" {
  type      = string
  sensitive = false
}

variable "loadbalancer_hc_port" {
  type      = number
  sensitive = false
}

variable "loadbalancer_hc_interval" {
  type      = number
  sensitive = false
}

variable "loadbalancer_hc_timeout" {
  type      = number
  sensitive = false
}

variable "loadbalancer_hc_retries" {
  type      = number
  sensitive = false
}

variable "loadbalancer_hc_http_domain" {
  default   = ""
  type      = string
  sensitive = false
}

variable "loadbalancer_hc_http_path" {
  default   = "/"
  type      = string
  sensitive = false
}

variable "loadbalancer_hc_http_response" {
  default   = ""
  type      = string
  sensitive = false
}

variable "loadbalancer_hc_http_tls" {
  default   = false
  type      = bool
  sensitive = false
}

variable "loadbalancer_hc_http_status_codes" {
  default   = ["2??", "3??"]
  type      = list(string)
  sensitive = false
}
