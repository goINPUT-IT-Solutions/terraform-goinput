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
### Random names and passwords
##############################

##############################
### Jitsi Server
##############################

resource "hcloud_server" "jitsi" {
  count       = var.jitsi_count
  name        = (count.index >= 9 ? "jitsi${count.index + 1}.${var.environment}.${var.domain}" : "jitsi0${count.index + 1}.${var.environment}.${var.domain}")
  image       = "debian-11"
  server_type = "cx21"

  ssh_keys = [
    "${var.terraform_ssh_key_id}",
    "${var.terraform_private_ssh_key_id}"
  ]

  labels = {
    distribution = "debian-11"
    service      = "jitsi"
    terraform    = true
  }

  location = (count.index % 2 == 0 ? "fsn1" : "nbg1")

  firewall_ids = [
    var.firewall_default_id,
    var.firewall_webservice_id
  ]
}

resource "hcloud_server_network" "jitsi_network" {
  count = length(hcloud_server.jitsi)

  server_id  = hcloud_server.jitsi[count.index].id
  network_id = var.network_webservice_id
}

##############################
### REVERSE DNS
##############################

resource "hcloud_rdns" "jitsi_rdns_ipv4" {
  count = length(hcloud_server.jitsi)

  server_id  = hcloud_server.jitsi[count.index].id
  ip_address = hcloud_server.jitsi[count.index].ipv4_address
  dns_ptr    = hcloud_server.jitsi[count.index].name
}

resource "hcloud_rdns" "jitsi_rdns_ipv6" {
  count = length(hcloud_server.jitsi)

  server_id  = hcloud_server.jitsi[count.index].id
  ip_address = hcloud_server.jitsi[count.index].ipv6_address
  dns_ptr    = hcloud_server.jitsi[count.index].name
}

##############################
### DNS
##############################

resource "cloudflare_record" "jitsi_dns_ipv4" {
  count = length(hcloud_server.jitsi)

  zone_id = var.dns_zone
  name    = hcloud_server.jitsi[count.index].name
  value   = hcloud_server.jitsi[count.index].ipv4_address
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "jitsi_dns_ipv6" {
  count = length(hcloud_server.jitsi)

  zone_id = var.dns_zone
  name    = hcloud_server.jitsi[count.index].name
  value   = hcloud_server.jitsi[count.index].ipv6_address
  type    = "AAAA"
  ttl     = 3600
}
