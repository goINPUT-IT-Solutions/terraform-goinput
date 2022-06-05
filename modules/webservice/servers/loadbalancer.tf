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

resource "hcloud_load_balancer" "loadbalancer" {
  count              = (var.server_count > 1 ? 1 : 0)
  name               = (count.index >= 9 ? "${var.server_name}-lb${count.index + 1}.${var.environment}.${var.domain}" : "${var.server_name}-lb0${count.index + 1}.${var.environment}.${var.domain}")
  load_balancer_type = (var.server_count > 75 ? "lb31" : var.server_count > 25 ? "lb21" : "lb11")
  location           = (count.index % 2 == 0 ? "fsn1" : "nbg1")
}

resource "hcloud_load_balancer_network" "loadbalancer_network" {
  count            = length(hcloud_load_balancer.loadbalancer)
  load_balancer_id = hcloud_load_balancer.loadbalancer[count.index].id
  network_id       = var.network_id
}

resource "hcloud_load_balancer_service" "loadbalancer_service_http" {
  count            = length(hcloud_load_balancer.loadbalancer)
  load_balancer_id = hcloud_load_balancer.loadbalancer[count.index].id
  protocol         = "http"
  proxyprotocol    = false
}

resource "hcloud_load_balancer_target" "loadbalancer_target" {
  depends_on = [
    hcloud_load_balancer_network.loadbalancer_network
  ]

  count            = length(hcloud_load_balancer.loadbalancer)
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.loadbalancer[count.index].id
  use_private_ip   = true

  label_selector = join("", [for key, value in var.server_labels : (key == "service" ? "${key}=${value}" : "")])
}

##############################
### REVERSE DNS
##############################

resource "hcloud_rdns" "loadbalancer_rdns_ipv4" {
  count = length(hcloud_load_balancer.loadbalancer)

  load_balancer_id = hcloud_load_balancer.loadbalancer[count.index].id
  ip_address       = hcloud_load_balancer.loadbalancer[count.index].ipv4
  dns_ptr          = hcloud_load_balancer.loadbalancer[count.index].name
}

resource "hcloud_rdns" "loadbalancer_rdns_ipv6" {
  count = length(hcloud_load_balancer.loadbalancer)

  load_balancer_id = hcloud_load_balancer.loadbalancer[count.index].id
  ip_address       = hcloud_load_balancer.loadbalancer[count.index].ipv6
  dns_ptr          = hcloud_load_balancer.loadbalancer[count.index].name
}

##############################
### DNS
##############################

resource "cloudflare_record" "loadbalancer_dns_ipv4" {
  count = length(hcloud_load_balancer.loadbalancer)

  zone_id = var.dns_zone
  name    = hcloud_load_balancer.loadbalancer[count.index].name
  value   = hcloud_load_balancer.loadbalancer[count.index].ipv4
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "loadbalancer_dns_ipv6" {
  count = length(hcloud_load_balancer.loadbalancer)

  zone_id = var.dns_zone
  name    = hcloud_load_balancer.loadbalancer[count.index].name
  value   = hcloud_load_balancer.loadbalancer[count.index].ipv6
  type    = "AAAA"
  ttl     = 3600
}
