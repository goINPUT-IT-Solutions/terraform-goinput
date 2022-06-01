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

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.15.0"
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
### Names and passwords
##############################

resource "random_password" "mailserver_random_root_pw" {
  length  = 64
  special = false
}

resource "random_password" "mailserver_random_mailcow_pw" {
  length  = 64
  special = false
}

##############################
### Mailserver
##############################

resource "hcloud_server" "mailserver" {
  name        = "mail01.${var.environment}.${var.domain}"
  image       = "ubuntu-22.04"
  server_type = "cx31"

  ssh_keys = [
    "${var.terraform_ssh_key_id}",
    "${var.terraform_private_ssh_key_id}"
  ]
  location = "fsn1"

  firewall_ids = [
    var.firewall_default_id,
    var.firewall_mailserver_id
  ]
}

resource "hcloud_server_network" "mailserver_network" {
  server_id  = hcloud_server.mailserver.id
  network_id = var.network_webservice_id
}

resource "hcloud_volume_attachment" "log_volume" {
  volume_id = hcloud_volume.log_volume.id
  server_id = hcloud_server.mailserver.id
}

resource "hcloud_volume_attachment" "mail_volume" {
  volume_id = hcloud_volume.mail_volume.id
  server_id = hcloud_server.mailserver.id
}

##############################
### DNS ENTRIES
##############################

module "dns_zones" {
  for_each = var.domains_zone_id

  source = "./modules/dns_entries"

  # Variables
  zone_id             = each.key
  mailserver_hostname = hcloud_server.mailserver.name
}

##############################
### REVERSE DNS
##############################

resource "hcloud_rdns" "mailserver_rdns_ipv4" {
  server_id  = hcloud_server.mailserver.id
  ip_address = hcloud_server.mailserver.ipv4_address
  dns_ptr    = hcloud_server.mailserver.name
}

resource "hcloud_rdns" "mailserver_rdns_ipv6" {
  server_id  = hcloud_server.mailserver.id
  ip_address = hcloud_server.mailserver.ipv6_address
  dns_ptr    = hcloud_server.mailserver.name
}

##############################
### DNS
##############################

resource "cloudflare_record" "mailserver_dns_ipv4" {
  zone_id = var.cloudflare_goitservers_com_zone_id
  name    = hcloud_server.mailserver.name
  value   = hcloud_server.mailserver.ipv4_address
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "mailserver_dns_ipv6" {
  zone_id = var.cloudflare_goitservers_com_zone_id
  name    = hcloud_server.mailserver.name
  value   = hcloud_server.mailserver.ipv6_address
  type    = "AAAA"
  ttl     = 3600
}

##############################
### Bitwarden
##############################


