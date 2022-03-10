####################################################################
#                      _____ _   _ _____  _    _ _______           #
#                     |_   _| \ | |  __ \| |  | |__   __|          #
#            __ _  ___  | | |  \| | |__) | |  | |  | |             #
#           / _` |/ _ \ | | | . ` |  ___/| |  | |  | |             #
#          | (_| | (_) || |_| |\  | |    | |__| |  | |             #
#           \__, |\___/_____|_| \_|_|     \____/   |_|             #
#            __/ |                                                 #
#           |___/                                                  #
#                                                                  #
####################################################################

variable "hetzner_token" {
  sensitive = true
  type      = string
}

variable "ssh_key" {
    type = string
}

variable "domain" {
  default = "goitservers.com"
    type = string
}

variable "betteruptime_api" {
    sensitive = true
    type = string
}

########################
# Netcup
########################

variable "netcup_customer_id" {
    type = string
    sensitive = true
}
variable "netcup_ccp_api_key" {
    type = string
    sensitive = true
}
variable "netcup_ccp_api_pw" {
    type = string
    sensitive = true
}

########################
# SMTP
########################

variable "smtp_host" {
  type = string
}

variable "smtp_port" {
  type = number
}

variable "smtp_username" {
  type = string
  sensitive = true
}

variable "smtp_password" {
  type = string
  sensitive = true
}

variable "smtp_from" {
  type = string
  sensitive = true
}

variable "smtp_to" {
  type = list(string)
  sensitive = true
}
