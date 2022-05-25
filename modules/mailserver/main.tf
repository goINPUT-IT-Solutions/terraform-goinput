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
    powerdns = {
      source  = "pan-net/powerdns"
      version = "~> 1.5"
    }

    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
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
### Names and passwords
##############################

resource "random_pet" "mailserver_names" {
  length = 1
}

resource "random_password" "mailserver_random_root_pw" {
  length  = 64
  special = false
}

resource "random_password" "mailserver_random_mailcow_pw" {
  length  = 64
  special = false
}

##############################
### Mailserver
##############################

resource "hcloud_server" "mailserver" {
  name        = "${random_pet.mailserver_names.id}.${var.service_name}.${var.domain}"
  image       = "ubuntu-22.04"
  server_type = "cx31"

  ssh_keys = ["${var.terraform_ssh_key_id}"]
  location = "fsn1"

  network {
    network_id = var.network_webservice_id
  }

  firewall_ids = [
    var.firewall_default_id,
    var.firewall_mailserver_id
  ]

  user_data = templatefile(abspath("${path.root}/scripts/cloud-init/init-mailserver.yml"), {
    root_pw    = random_password.mailserver_random_root_pw.result
    mailcow_pw = random_password.mailserver_random_mailcow_pw.result

    # Volumes
    log_volume_linux_device  = "${hcloud_volume.log_volume.linux_device}"
    mail_volume_linux_device = "${hcloud_volume.mail_volume.linux_device}"

    depends_on = [
      hcloud_volume.log_volume,
      hcloud_volume.mail_volume
    ]
  })
}

resource "hcloud_volume_attachment" "log_volume" {
  volume_id = hcloud_volume.log_volume.id
  server_id = hcloud_server.mailserver.id
}

resource "hcloud_volume_attachment" "mail_volume" {
  volume_id = hcloud_volume.mail_volume.id
  server_id = hcloud_server.mailserver.id
}


##############################
### REVERSE DNS
##############################

resource "hcloud_rdns" "mailserver_rdns_ipv4" {
  server_id  = hcloud_server.mailserver.id
  ip_address = hcloud_server.mailserver.ipv4_address
  dns_ptr    = hcloud_server.mailserver.name
}

resource "hcloud_rdns" "mailserver_rdns_ipv6" {
  server_id  = hcloud_server.mailserver.id
  ip_address = hcloud_server.mailserver.ipv6_address
  dns_ptr    = hcloud_server.mailserver.name
}

##############################
### Bitwarden
##############################


