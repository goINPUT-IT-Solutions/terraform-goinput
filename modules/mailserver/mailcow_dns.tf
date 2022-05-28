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

/// Mailcow DNS Settings


/*
# DOMAIN: goitservers.com
resource "cloudflare_record" "mailserver_dns_goitservers_com_mail_cnames" {
  zone_id = var.cloudflare_goitservers_com_zone_id

  for_each = toset([
    "mails",
    "mail",
    "autodiscover",
    "autoconfig"
  ])

  name  = each.key
  value = hcloud_server.mailserver.name
  type  = "CNAME"
  ttl   = 3600
}

resource "cloudflare_record" "mailserver_dns_goitservers_com_mail_mx" {
  zone_id = var.cloudflare_goitservers_com_zone_id

  for_each = toset([
    "@",
    "*"
  ])

  name     = each.key
  value    = hcloud_server.mailserver.name
  type     = "MX"
  ttl      = 3600
  priority = "10"
}

resource "cloudflare_record" "mailserver_dns_goitservers_com_mail_txts" {
  zone_id = var.cloudflare_goitservers_com_zone_id

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

resource "cloudflare_record" "mailserver_dns_goitservers_com_mail_srvs" {
  zone_id = var.cloudflare_goitservers_com_zone_id

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
    target   = hcloud_server.mailserver.name
  }
}

# DOMAIN: goinput.de
resource "cloudflare_record" "mailserver_dns_cname_goinput_de_mails" {
  zone_id = var.cloudflare_goinput_de_zone_id
  name    = "mails.goinput.de"
  value   = hcloud_server.mailserver.name
  type    = "CNAME"
  ttl     = 3600
}

resource "cloudflare_record" "mailserver_dns_cname_goinput_de_mail" {
  zone_id = var.cloudflare_goinput_de_zone_id
  name    = "mail.goinput.de"
  value   = hcloud_server.mailserver.name
  type    = "CNAME"
  ttl     = 3600
}

resource "cloudflare_record" "mailserver_dns_cname_goinput_de_autodiscover" {
  zone_id = var.cloudflare_goinput_de_zone_id
  name    = "autodiscover.goinput.de"
  value   = hcloud_server.mailserver.name
  type    = "CNAME"
  ttl     = 3600
}

resource "cloudflare_record" "mailserver_dns_cname_goinput_de_autoconfig" {
  zone_id = var.cloudflare_goinput_de_zone_id
  name    = "autoconfig.goinput.de"
  value   = hcloud_server.mailserver.name
  type    = "CNAME"
  ttl     = 3600
}

resource "cloudflare_record" "mailserver_dns_mx_goinput_de_root" {
  zone_id  = var.cloudflare_goinput_de_zone_id
  name     = "goinput.de"
  value    = hcloud_server.mailserver.name
  type     = "MX"
  ttl      = 3600
  priority = "10"
}

resource "cloudflare_record" "mailserver_dns_mx_goinput_de_wildcard" {
  zone_id  = var.cloudflare_goinput_de_zone_id
  name     = "*.goinput.de"
  value    = hcloud_server.mailserver.name
  type     = "MX"
  ttl      = 3600
  priority = "10"
}

resource "cloudflare_record" "mailserver_dns_txt_goinput_de_spf" {
  zone_id = var.cloudflare_goinput_de_zone_id
  name    = "goinput.de"
  value   = "v=spf1 mx a ~all"
  type    = "TXT"
  ttl     = 3600
}
*/
