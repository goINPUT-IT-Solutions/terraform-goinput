####################################################################
#                      _____ _   _ _____  _    _ _______           #
#                     |_   _| \ | |  __ \| |  | |__   __|          #
#            __ _  ___  | | |  \| | |__) | |  | |  | |             #
#           / _` |/ _ \ | | | . ` |  ___/| |  | |  | |             #
#          | (_| | (_) || |_| |\  | |    | |__| |  | |             #
#           \__, |\___/_____|_| \_|_|     \____/   |_|             #
#            __/ |                                                 #
#           |___/                                                  #
#                                                                  #
####################################################################

data "template_file" "template_new_server_created" {
    template = file("./mail_templates/server_created.html")

    vars = {
      "server_name"           = hcloud_server.jitsi-main.name
      "server_ipv4"           = hcloud_server.jitsi-main.ipv4_address
      "server_ipv6"           = hcloud_server.jitsi-main.ipv6_address
      "server_root_password"  = random_string.jitsi_main_random_root_password.result
    }
}

module "smtp-mail" {
  source        = "github.com/goINPUT-IT-Solutions/terraform-null-smtp-mail"
  host          = var.smtp_host
  port          = var.smtp_port
  username      = var.smtp_username
  password      = var.smtp_password
  html          = true
  from          = var.smtp_from
  to            = var.smtp_to
  subject       = "goINPUT Server ${hcloud_server.jitsi-main.name} created"
  body          = data.template_file.template_new_server_created.rendered

  depends_on = [
    hcloud_server.jitsi-main
  ]
}

resource "random_string" "jitsi_main_random_root_password" {
  length           = 32
  special          = false
  override_special = "_%@"
}

data "template_file" "jitsi_user_data" {
    template = file("./cloud-init/jitsi-main.yml")

    vars = {
      "root_password" = random_string.jitsi_main_random_root_password.result
    }
}

resource "hcloud_server" "jitsi-main" {
    name        = "ruffy.${var.domain}"
    image       = "ubuntu-20.04"
    server_type = "cx11"

    location    = "fsn1"
    backups     = true

    ssh_keys    =  [
        hcloud_ssh_key.default.id
    ] 

    labels      = {
        service         = "jitsi",
        chainofcommand  = "main",
        distribution    = "ubuntu"
    }

    user_data = data.template_file.jitsi_user_data.rendered
}

resource "hcloud_rdns" "jitsi-main_ipv4_rdns" {
  server_id  = hcloud_server.jitsi-main.id
  ip_address = hcloud_server.jitsi-main.ipv4_address
  dns_ptr    = hcloud_server.jitsi-main.name
}

resource "hcloud_rdns" "jitsi-main_ipv6_rdns" {
  server_id  = hcloud_server.jitsi-main.id
  ip_address = hcloud_server.jitsi-main.ipv6_address
  dns_ptr    = hcloud_server.jitsi-main.name
}

resource "netcup-ccp_dns_record" "jitsi-main_dnsv4" {
  domain_name   = var.domain
  name          = "ruffy"
  type          = "A"
  value         = hcloud_server.jitsi-main.ipv4_address
  priority      = "0"               # for MX records
  depends_on = [
    hcloud_server.jitsi-main
  ]
}

resource "netcup-ccp_dns_record" "jitsi-main_dnsv6" {
  domain_name   = var.domain
  name          = "ruffy"
  type          = "AAAA"
  value         = hcloud_server.jitsi-main.ipv6_address
  priority      = "0"               # for MX records
  depends_on = [
    hcloud_server.jitsi-main
  ]
}

