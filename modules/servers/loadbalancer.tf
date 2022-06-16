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
  count              = try((var.server_count > 1 ? 1 : 0), 0)
  name               = (count.index >= 9 ? "${var.server_name}-lb${count.index + 1}.${var.environment}.${var.domain}" : "${var.server_name}-lb0${count.index + 1}.${var.environment}.${var.domain}")
  load_balancer_type = (var.server_count > 75 || length(var.loadbalancer_services) > 15 ? "lb31" : var.server_count > 25 || length(var.loadbalancer_services) > 5 ? "lb21" : "lb11")
  location           = (count.index % 2 == 0 ? "fsn1" : "nbg1")
}

resource "hcloud_load_balancer_network" "loadbalancer_network" {
  count            = try(length(hcloud_load_balancer.loadbalancer), 0)
  load_balancer_id = hcloud_load_balancer.loadbalancer[count.index].id
  network_id       = var.network_id
}

resource "hcloud_load_balancer_target" "loadbalancer_target" {
  depends_on = [
    hcloud_load_balancer_network.loadbalancer_network
  ]

  count            = try(length(hcloud_load_balancer.loadbalancer), 0)
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.loadbalancer[count.index].id
  use_private_ip   = true

  label_selector = join("", [for key, value in var.server_labels : (key == "service" ? "${key}=${value}" : "")])
}

##############################
### SERVICES
##############################

module "lb_service" {
  source = "./service"

  for_each = var.loadbalancer_services

  # Variables
  ## Loadbalancer
  loadbalancer_id = [
    for loadbalancer in hcloud_load_balancer.loadbalancer : loadbalancer.id
  ]
  loadbalancer_count            = try(length(hcloud_load_balancer.loadbalancer), 0)
  loadbalancer_protocol         = try(each.value.protocol, "http")
  loadbalancer_proxyprotocol    = try(each.value.proxyprotocol, false)
  loadbalancer_listen_port      = try(each.value.listen_port, 80)
  loadbalancer_destination_port = (can(each.value.destination_port) == true ? try(each.value.destination_port, 80) : try(each.value.listen_port, 80))

  ### Health Check
  loadbalancer_hc_protocol = try(each.value.health_check.protocol, "tcp")
  loadbalancer_hc_port     = try(each.value.health_check.port, 80)
  loadbalancer_hc_interval = try(each.value.health_check.interval, 30)
  loadbalancer_hc_timeout  = try(each.value.health_check.timeout, 30)
  loadbalancer_hc_retries  = try(each.value.health_check.retries, 10)

  #### HC: HTTP
  loadbalancer_hc_http_domain       = try(each.value.health_check.http.domain, "")
  loadbalancer_hc_http_path         = try(each.value.health_check.http.path, "/")
  loadbalancer_hc_http_response     = try(each.value.health_check.http.response, "")
  loadbalancer_hc_http_tls          = try(each.value.health_check.http.tls, false)
  loadbalancer_hc_http_status_codes = try(each.value.health_check.http.status_codes, ["2??", "3??"])

  ## Certificates
  goinput_certificate_id = var.goinput_certificate_id
  loadbalancer_certificate_id = [
    for certificate in hcloud_uploaded_certificate.loadbalancer_certificate : certificate.id
  ]

  # Depends
  depends_on = [
    hcloud_load_balancer.loadbalancer
  ]
}

##############################
### REVERSE DNS
##############################

resource "hcloud_rdns" "loadbalancer_rdns_ipv4" {
  count = try(length(hcloud_load_balancer.loadbalancer), 0)

  load_balancer_id = hcloud_load_balancer.loadbalancer[count.index].id
  ip_address       = hcloud_load_balancer.loadbalancer[count.index].ipv4
  dns_ptr          = hcloud_load_balancer.loadbalancer[count.index].name
}

resource "hcloud_rdns" "loadbalancer_rdns_ipv6" {
  count = try(length(hcloud_load_balancer.loadbalancer), 0)

  load_balancer_id = hcloud_load_balancer.loadbalancer[count.index].id
  ip_address       = hcloud_load_balancer.loadbalancer[count.index].ipv6
  dns_ptr          = hcloud_load_balancer.loadbalancer[count.index].name
}

##############################
### DNS
##############################

resource "cloudflare_record" "loadbalancer_dns_ipv4" {
  count = try(length(hcloud_load_balancer.loadbalancer), 0)

  zone_id = var.dns_zone
  name    = hcloud_load_balancer.loadbalancer[count.index].name
  value   = hcloud_load_balancer.loadbalancer[count.index].ipv4
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "loadbalancer_dns_ipv6" {
  count = try(length(hcloud_load_balancer.loadbalancer), 0)

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
  count     = try(length(hcloud_load_balancer.loadbalancer), 0)
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "loadbalancer_certificate_request" {
  count           = try(length(hcloud_load_balancer.loadbalancer), 0)
  private_key_pem = tls_private_key.loadbalancer_certificate_private_key[count.index].private_key_pem

  subject {
    common_name = hcloud_load_balancer.loadbalancer[count.index].name
  }
}

resource "acme_certificate" "loadbalancer_certificate" {
  count                   = try(length(hcloud_load_balancer.loadbalancer), 0)
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
  count = try(length(hcloud_load_balancer.loadbalancer), 0)
  name  = hcloud_load_balancer.loadbalancer[count.index].name

  private_key = tls_private_key.loadbalancer_certificate_private_key[count.index].private_key_pem
  certificate = "${acme_certificate.loadbalancer_certificate[count.index].certificate_pem}${acme_certificate.loadbalancer_certificate[count.index].issuer_pem}"

  labels = {
    certificate = hcloud_load_balancer.loadbalancer[count.index].name
    wildcard    = false
    terraform   = true
  }
}
