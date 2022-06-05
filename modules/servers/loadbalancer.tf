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
  count            = (var.loadbalancer_protocol == "https" ? length(hcloud_load_balancer.loadbalancer) : 0)
  load_balancer_id = hcloud_load_balancer.loadbalancer[count.index].id
  protocol         = var.loadbalancer_protocol
  proxyprotocol    = var.loadbalancer_proxyprotocol
  listen_port      = var.loadbalancer_listen_port
  destination_port = var.loadbalancer_destination_port

  http {
    certificates  = (var.loadbalancer_protocol == "https" ? [hcloud_uploaded_certificate.loadbalancer_certificate[count.index].id, var.goinput_certificate_id] : [])
    redirect_http = (var.loadbalancer_protocol == "https" ? true : false)
  }

  health_check {
    protocol = var.loadbalancer_hc_protocol
    port     = var.loadbalancer_hc_port
    interval = var.loadbalancer_hc_interval
    timeout  = var.loadbalancer_hc_timeout
    retries  = var.loadbalancer_hc_retries

    http {
      domain       = var.loadbalancer_hc_http_domain
      path         = var.loadbalancer_hc_http_path
      response     = var.loadbalancer_hc_http_response
      tls          = var.loadbalancer_hc_http_tls
      status_codes = var.loadbalancer_hc_http_status_codes
    }
  }
}

resource "hcloud_load_balancer_service" "loadbalancer_service_tcp" {
  count            = (var.loadbalancer_protocol == "tcp" ? length(hcloud_load_balancer.loadbalancer) : 0)
  load_balancer_id = hcloud_load_balancer.loadbalancer[count.index].id
  protocol         = var.loadbalancer_protocol
  proxyprotocol    = var.loadbalancer_proxyprotocol
  listen_port      = var.loadbalancer_listen_port
  destination_port = var.loadbalancer_destination_port

  health_check {
    protocol = var.loadbalancer_hc_protocol
    port     = var.loadbalancer_hc_port
    interval = var.loadbalancer_hc_interval
    timeout  = var.loadbalancer_hc_timeout
    retries  = var.loadbalancer_hc_retries
  }
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

##############################
### Certificates
##############################

resource "tls_private_key" "loadbalancer_certificate_private_key" {
  count     = length(hcloud_load_balancer.loadbalancer)
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "loadbalancer_certificate_request" {
  count           = length(hcloud_load_balancer.loadbalancer)
  private_key_pem = tls_private_key.loadbalancer_certificate_private_key[count.index].private_key_pem

  subject {
    common_name = hcloud_load_balancer.loadbalancer[count.index].name
  }
}

resource "acme_certificate" "loadbalancer_certificate" {
  count                   = length(hcloud_load_balancer.loadbalancer)
  account_key_pem         = var.acme_account_key
  certificate_request_pem = tls_cert_request.loadbalancer_certificate_request[count.index].cert_request_pem

  dns_challenge {
    provider = "cloudflare"

    config = {
      CF_API_EMAIL = var.cloudflare_email
      CF_API_KEY   = var.cloudflare_api_key
    }
  }
}

resource "hcloud_uploaded_certificate" "loadbalancer_certificate" {
  count = length(hcloud_load_balancer.loadbalancer)
  name  = hcloud_load_balancer.loadbalancer[count.index].name

  private_key = tls_private_key.loadbalancer_certificate_private_key[count.index].private_key_pem
  certificate = "${acme_certificate.loadbalancer_certificate[count.index].certificate_pem}${acme_certificate.loadbalancer_certificate[count.index].issuer_pem}"

  labels = {
    certificate = hcloud_load_balancer.loadbalancer[count.index].name
    wildcard    = false
    terraform   = true
  }
}
