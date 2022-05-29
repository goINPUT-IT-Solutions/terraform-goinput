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
### Random names and passwords
##############################

resource "random_pet" "database_names" {
  length = 1
  count  = var.server_count
}

##############################
### Database Server
##############################

resource "hcloud_server" "database" {
  count       = var.server_count
  name        = "${random_pet.database_names[count.index].id}.${var.service_name}.${var.environment}.${var.domain}"
  image       = "ubuntu-20.04"
  server_type = "cx11"

  ssh_keys = [
    "${var.terraform_ssh_key_id}",
    "${var.terraform_private_ssh_key_id}",
  ]
  location = "fsn1"

  firewall_ids = [
    var.firewall_default_id
  ]
}

resource "hcloud_server_network" "database_network" {
  count = length(hcloud_server.database)

  server_id  = hcloud_server.database[count.index].id
  network_id = var.network_webservice_id
}

##############################
### REVERSE DNS
##############################

resource "hcloud_rdns" "database_rdns_ipv4" {
  count = length(hcloud_server.database)

  server_id  = hcloud_server.database[count.index].id
  ip_address = hcloud_server.database[count.index].ipv4_address
  dns_ptr    = hcloud_server.database[count.index].name
}

resource "hcloud_rdns" "database_rdns_ipv6" {
  count = length(hcloud_server.database)

  server_id  = hcloud_server.database[count.index].id
  ip_address = hcloud_server.database[count.index].ipv6_address
  dns_ptr    = hcloud_server.database[count.index].name
}

##############################
### DNS
##############################

resource "cloudflare_record" "database_dns_ipv4" {
  count = length(hcloud_server.database)

  zone_id = var.cloudflare_goitservers_com_zone_id
  name    = hcloud_server.database[count.index].name
  value   = hcloud_server.database[count.index].ipv4_address
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "database_dns_ipv6" {
  count = length(hcloud_server.database)

  zone_id = var.cloudflare_goitservers_com_zone_id
  name    = hcloud_server.database[count.index].name
  value   = hcloud_server.database[count.index].ipv6_address
  type    = "AAAA"
  ttl     = 3600
}


