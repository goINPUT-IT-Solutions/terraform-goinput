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

resource "hcloud_load_balancer" "loadbalancer" {
  count              = (var.server_count > 1 ? 1 : 0)
  name               = "${var.server_name}-lb.${var.environment}.${var.domain}"
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
