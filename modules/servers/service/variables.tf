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
### Loadbalancer
##############################

variable "loadbalancer_id" {
  type      = list(string)
  sensitive = false
}

variable "loadbalancer_count" {
  default   = 0
  type      = number
  sensitive = false
}

variable "loadbalancer_proxyprotocol" {
  default   = false
  type      = bool
  sensitive = false
}

variable "loadbalancer_protocol" {
  default   = "tcp"
  type      = string
  sensitive = false
}

variable "loadbalancer_destination_port" {
  default   = 80
  type      = number
  sensitive = false
}

variable "loadbalancer_listen_port" {
  default   = 80
  type      = number
  sensitive = false
}

##############################
### LB: Health Check
##############################

variable "loadbalancer_hc_protocol" {
  default   = "tcp"
  type      = string
  sensitive = false
}

variable "loadbalancer_hc_port" {
  default   = 80
  type      = number
  sensitive = false
}

variable "loadbalancer_hc_interval" {
  default   = 10
  type      = number
  sensitive = false
}

variable "loadbalancer_hc_timeout" {
  default   = 10
  type      = number
  sensitive = false
}

variable "loadbalancer_hc_retries" {
  default   = 5
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

##############################
### Certificates
##############################

variable "goinput_certificate_id" {
  type      = string
  sensitive = false
}

variable "loadbalancer_certificate_id" {
  type      = list(string)
  sensitive = false
}
