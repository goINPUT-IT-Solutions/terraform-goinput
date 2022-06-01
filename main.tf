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
  cloud {
    organization = "goINPUT"

    workspaces {
      name = "infrastructure-main"
    }
  }

  required_providers {
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

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.15.0"
    }
  }
}

##############################
### Cloudflare
##############################

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

##############################
### Hetzner
##############################

provider "hcloud" {
  token = var.hcloud_token
}

data "hcloud_ssh_key" "hcloud_terraform_ssh_key" {
  name = "Javik OpenSSH Key for Stargazer"
}

resource "tls_private_key" "terraform_private_key" {
  algorithm = "ED25519"
}

resource "hcloud_ssh_key" "terraform_private_key" {
  name       = "Terraform Private Key"
  public_key = tls_private_key.terraform_private_key.public_key_openssh
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

  nameserver_network_name     = "${var.nameserver_network_name}-${var.environment}"
  nameserver_network_ip_range = var.nameserver_network_ip_range

  mailserver_network_name     = "${var.mailserver_network_name}-${var.environment}"
  mailserver_network_ip_range = var.mailserver_network_ip_range

  webservice_network_name     = "${var.webservice_network_name}-${var.environment}"
  webservice_network_ip_range = var.webservice_network_ip_range

  ##### Dependencies

  depends_on = [
    module.firewall
  ]
}

module "salt" {
  source = "./modules/salt"

  ###### Variables

  // SSH
  terraform_ssh_key_id         = data.hcloud_ssh_key.hcloud_terraform_ssh_key.id
  terraform_private_ssh_key_id = hcloud_ssh_key.terraform_private_key.id
  terraform_private_ssh_key    = tls_private_key.terraform_private_key.private_key_openssh

  domain      = var.domain
  environment = var.environment

  // FIREWALLS
  firewall_default_id     = module.firewall.firewall_default_id
  firewall_saltbastion_id = module.firewall.firewall_saltbastion_id

  // Networks
  network_webservice_id = module.networks.webservice_network_id

  // Cloudflare
  cloudflare_email                   = var.cloudflare_email
  cloudflare_api_key                 = var.cloudflare_api_key
  cloudflare_goitservers_com_zone_id = data.cloudflare_zone.dns_zones[var.domain].zone_id

  ##### Dependencies

  depends_on = [
    module.firewall,
    module.networks
  ]
}

module "database" {
  source = "./modules/database"

  ###### Variables

  // SSH
  terraform_ssh_key_id         = data.hcloud_ssh_key.hcloud_terraform_ssh_key.id
  terraform_private_ssh_key_id = hcloud_ssh_key.terraform_private_key.id
  terraform_private_ssh_key    = tls_private_key.terraform_private_key.private_key_openssh

  service_name = "db"
  domain       = var.domain
  environment  = var.environment
  server_count = 1

  saltmaster_ip        = module.salt.saltstack_webservice_network_ip
  saltmaster_public_ip = module.salt.saltstack_public_ipv4

  // Cloudflare
  cloudflare_goitservers_com_zone_id = data.cloudflare_zone.dns_zones[var.domain].zone_id

  /// Networks and Firewall configuration
  network_webservice_id = module.networks.webservice_network_id
  firewall_default_id   = module.firewall.firewall_default_id

  ##### Dependencies

  depends_on = [
    module.firewall,
    module.networks,
    module.salt
  ]
}

module "mailserver" {
  source = "./modules/mailserver"

  ###### Variables

  // SSH
  terraform_ssh_key_id         = data.hcloud_ssh_key.hcloud_terraform_ssh_key.id
  terraform_private_ssh_key_id = hcloud_ssh_key.terraform_private_key.id
  terraform_private_ssh_key    = tls_private_key.terraform_private_key.private_key_openssh

  service_name = "mail"
  domain       = var.domain
  environment  = var.environment
  server_count = 1

  /// Networks and Firewall configuration
  network_webservice_id  = module.networks.webservice_network_id
  firewall_default_id    = module.firewall.firewall_default_id
  firewall_mailserver_id = module.firewall.firewall_mailserver_id

  saltmaster_ip        = module.salt.saltstack_webservice_network_ip
  saltmaster_public_ip = module.salt.saltstack_public_ipv4

  // Cloudflare
  cloudflare_goitservers_com_zone_id = data.cloudflare_zone.dns_zones[var.domain].zone_id
  cloudflare_goinput_de_zone_id      = data.cloudflare_zone.goinput_de.zone_id

  domains_zone_id = [
    for domain in data.cloudflare_zone.dns_zones : domain.zone_id
  ]

  ##### Dependencies

  depends_on = [
    module.firewall,
    module.networks,
    module.salt,
    module.database
  ]
}

module "webservice" {
  source = "./modules/webservice"

  ###### Variables

  // SSH
  terraform_ssh_key_id         = data.hcloud_ssh_key.hcloud_terraform_ssh_key.id
  terraform_private_ssh_key_id = hcloud_ssh_key.terraform_private_key.id
  terraform_private_ssh_key    = tls_private_key.terraform_private_key.private_key_openssh

  service_name = "web"
  domain       = var.domain
  environment  = var.environment

  # Server Counts
  apache_count = 3

  saltmaster_ip        = module.salt.saltstack_webservice_network_ip
  saltmaster_public_ip = module.salt.saltstack_public_ipv4

  /// Networks and Firewall configuration
  network_webservice_id  = module.networks.webservice_network_id
  firewall_default_id    = module.firewall.firewall_default_id
  firewall_webservice_id = module.firewall.firewall_webservice_id

  ##### Dependencies

  depends_on = [
    module.firewall,
    module.networks,
    module.mailserver,
    module.salt,
    module.database
  ]
}
