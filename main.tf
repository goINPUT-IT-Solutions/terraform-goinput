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
### Required providers
##############################

terraform {
  required_providers {
    powerdns = {
      source  = "pan-net/powerdns"
      version = "~> 1.5"
    }

    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }

    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.33.2"
    }

    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "~> 0.2.0"
    }
  }
}

##############################
### Hetzner
##############################

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "hcloud_terraform_ssh_key" {
  name       = "Terraform"
  public_key = file(abspath("${path.root}/${var.terraform_ssh_key}.pub"))
}

##############################
### PowerDNS
##############################

provider "powerdns" {
  api_key    = ""
  server_url = ""
}

##############################
### Bitwarden
##############################

provider "bitwarden" {
  master_password = var.bitwarden_master_password
  client_id       = var.bitwarden_client_id
  client_secret   = var.bitwarden_client_secret
  email           = var.bitwarden_email
  server          = var.bitwarden_server
}

##############################
### goINPUT Modules
##############################

module "firewall" {
  source = "./modules/firewall"

  ###### Variables

  ##### Dependencies
}

module "networks" {
  source = "./modules/networks"

  ###### Variables

  nameserver_network_name     = var.nameserver_network_name
  nameserver_network_ip_range = var.nameserver_network_ip_range

  mailserver_network_name     = var.mailserver_network_name
  mailserver_network_ip_range = var.mailserver_network_ip_range

  webservice_network_name     = var.webservice_network_name
  webservice_network_ip_range = var.webservice_network_ip_range

  ##### Dependencies

  depends_on = [
    module.firewall
  ]
}

module "saltbastion" {
  source = "./modules/saltbastion"

  ###### Variables

  terraform_ssh_key_id  = hcloud_ssh_key.hcloud_terraform_ssh_key.id
  domain                = var.domain
  firewall_default_id   = module.firewall.firewall_default_id
  network_webservice_id = module.networks.webservice_network_id

  ##### Dependencies

  depends_on = [
    module.firewall,
    module.networks
  ]
}

module "nameserver" {
  source = "./modules/nameserver"

  ###### Variables

  terraform_ssh_key_id = hcloud_ssh_key.hcloud_terraform_ssh_key.id
  service_name         = "ns"
  domain               = "goitdns.com"
  server_count         = 0

  ##### Dependencies

  depends_on = [
    module.firewall,
    module.networks,
    module.saltbastion
  ]
}

module "mailserver" {
  source = "./modules/mailserver"

  ###### Variables

  terraform_ssh_key_id = hcloud_ssh_key.hcloud_terraform_ssh_key.id
  service_name         = "mail"
  domain               = var.domain
  server_count         = 1

  /// Networks and Firewall configuration
  network_webservice_id  = module.networks.webservice_network_id
  firewall_default_id    = module.firewall.firewall_default_id
  firewall_mailserver_id = module.firewall.firewall_mailserver_id

  ##### Dependencies

  depends_on = [
    module.firewall,
    module.networks,
    module.nameserver,
    module.saltbastion
  ]
}

module "webservice" {
  source = "./modules/webservice"

  ###### Variables


  ##### Dependencies

  depends_on = [
    module.firewall,
    module.networks,
    module.nameserver,
    module.mailserver,
    module.saltbastion
  ]
}
