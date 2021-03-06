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
  }
}

data "cloudflare_zone" "dns_zone" {
  name = var.domain_name
}

resource "cloudflare_record" "domain_dns_ipv4" {
  count   = var.srv_count
  zone_id = data.cloudflare_zone.dns_zone.zone_id
  name    = var.domain_subdomain
  value   = var.domain_ipv4
  type    = "A"
  ttl     = var.domain_ttl
}

resource "cloudflare_record" "domain_dns_ipv6" {
  count   = var.srv_count
  zone_id = data.cloudflare_zone.dns_zone.zone_id
  name    = var.domain_subdomain
  value   = var.domain_ipv6
  type    = "AAAA"
  ttl     = var.domain_ttl
}
