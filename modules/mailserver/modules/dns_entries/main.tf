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

// Mailcow DNS Settings

# DOMAIN: goitservers.com
resource "cloudflare_record" "mailcow_dns_cnames" {
  zone_id = var.zone_id

  for_each = toset([
    "mails",
    "mail",
    "autodiscover",
    "autoconfig"
  ])

  name  = each.key
  value = var.mailserver_hostname
  type  = "CNAME"
  ttl   = 3600
}

resource "cloudflare_record" "mailcow_dns_mx" {
  zone_id = var.zone_id

  for_each = toset([
    "@",
    "*"
  ])

  name     = each.key
  value    = var.mailserver_hostname
  type     = "MX"
  ttl      = 3600
  priority = "10"
}

resource "cloudflare_record" "mailcow_dns_txts" {
  zone_id = var.zone_id

  for_each = tomap({
    "@"               = "v=spf1 mx a ~all"
    "_caldavs._tcp."  = "path=/SOGo/dav/"
    "_carddavs._tcp." = "path=/SOGo/dav/"
  })

  name  = each.key
  value = each.value
  type  = "TXT"
  ttl   = 3600
}

resource "cloudflare_record" "mailcow_dns_srvs" {
  zone_id = var.zone_id

  for_each = tomap({
    "_autodiscover" = "443"
    "_caldavs"      = "443"
    "_carddavs"     = "443"
    "_imap"         = "143"
    "_imaps"        = "993"
    "_pop3"         = "110"
    "_pop3s"        = "995"
    "_sieve"        = "4190"
    "_smtps"        = "465"
    "_submission"   = "587"
  })

  name = "@"
  type = "SRV"
  ttl  = 3600

  data {
    service  = each.key
    proto    = "_tcp"
    priority = 0
    weight   = 1
    port     = each.value
    target   = var.mailserver_hostname
  }
}