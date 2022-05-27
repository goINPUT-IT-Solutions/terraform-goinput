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

data "hcloud_locations" "locations" {
}

resource "random_pet" "nameserver_names" {
  count  = var.server_count
  length = 1
}

resource "random_password" "nameserver_random_root_pw" {
  count   = var.server_count
  length  = 64
  special = false
}

resource "hcloud_server" "nameserver" {
  count       = var.server_count
  name        = "${random_pet.nameserver_names[count.index].id}.${var.service_name}.${var.domain}"
  image       = "debian-11"
  server_type = "cx11"

  ssh_keys = ["${var.terraform_ssh_key_id}"]
  location = element(data.hcloud_locations.locations.names, count.index)

  user_data = templatefile(abspath("${path.root}/scripts/cloud-init/init-nameserver.yml"), {
    root_pw = random_password.nameserver_random_root_pw[count.index].result
  })
}

resource "bitwarden_item_login" "nameserver_root_pw" {
  count    = length(hcloud_server.nameserver)
  name     = hcloud_server.nameserver[count.index].name
  username = "root"
  password = random_password.nameserver_random_root_pw[count.index].result
}
