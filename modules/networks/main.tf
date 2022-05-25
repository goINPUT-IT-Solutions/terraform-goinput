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
### Required providers
##############################

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.33.2"
    }
  }
}

##############################
### Network: Nameserver
##############################

resource "hcloud_network" "hcloud_network_nameserver" {
  name     = var.nameserver_network_name
  ip_range = var.nameserver_network_ip_range

  labels = {
    "service" = "nameserver"
    "type"    = "network"
  }
}

resource "hcloud_network_subnet" "hcloud_network_nameserver_subnet" {
  network_id   = hcloud_network.hcloud_network_nameserver.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.nameserver_network_ip_range

  depends_on = [
    hcloud_network.hcloud_network_nameserver
  ]
}

##############################
### Network: Webservice
##############################

resource "hcloud_network" "hcloud_network_webservice" {
  name     = var.webservice_network_name
  ip_range = var.webservice_network_ip_range

  labels = {
    "service" = "webservice"
    "type"    = "network"
  }
}

resource "hcloud_network_subnet" "hcloud_network_webservice_subnet" {
  network_id   = hcloud_network.hcloud_network_webservice.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.webservice_network_ip_range

  depends_on = [
    hcloud_network.hcloud_network_webservice
  ]
}


