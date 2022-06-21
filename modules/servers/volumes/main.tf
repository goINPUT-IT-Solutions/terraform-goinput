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
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.33.2"
    }
  }
}

##############################
### Volumes
##############################

resource "hcloud_volume" "webservice_volume" {
  for_each = var.volumes

  name      = var.server_count < 10 ? "${each.key}0${var.server_count}" : "${each.key}${var.server_count}"
  size      = each.value.size
  automount = false
  format    = each.value.fs
  labels    = each.value.labels
}
