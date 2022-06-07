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
  count     = var.volume_count
  name      = (count.index >= 9 ? "${var.server_name}${count.index}-${var.volume_name}" : "${var.server_name}0${count.index}-${var.volume_name}")
  size      = var.volume_size
  server_id = var.volume_serverid[count.index]
  automount = false
  format    = var.volume_fs
}
