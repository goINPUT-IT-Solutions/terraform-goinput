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
### Servers
##############################

module "servers" {
  source = "./servers"

  for_each = {

    apache = {
      count  = var.apache_count
      type   = "cx11"
      image  = "debian-11"
      backup = false

      labels = {
        service      = "apache2"
        terraform    = true
        distribution = "debian-11"
      }
    }

    nextcloud = {
      count  = var.nextcloud_count
      type   = "cx21"
      image  = "ubuntu-22.04"
      backup = true

      labels = {
        service      = "nextcloud"
        terraform    = true
        distribution = "ubuntu-22.04"
      }
    }

    jitsi = {
      count  = var.jitsi_count
      type   = "cx21"
      image  = "ubuntu-22.04"
      backup = false

      labels = {
        service      = "jitsi"
        terraform    = true
        distribution = "ubuntu-22.04"
      }
    }

    wireguard = {
      count  = var.wireguard_count
      type   = "cx11"
      image  = "debian-11"
      backup = false

      labels = {
        service      = "wireguard"
        terraform    = true
        distribution = "debian-11"
      }
    }

    bitwarden = {
      count  = var.bitwarden_count
      type   = "cx11"
      image  = "debian-11"
      backup = false

      labels = {
        service      = "bitwarden"
        terraform    = true
        distribution = "debian-11"
      }
    }
  }

  # Variables
  ## Server name and count
  server_name   = each.key
  server_count  = try(each.value.count, 0)
  server_type   = try(each.value.type, "cx11")
  server_image  = try(each.value.image, "debian-11")
  server_backup = try(each.value.backup, false)
  server_labels = try(each.value.labels, "")

  ## Domain and environment
  domain      = var.domain
  environment = var.environment

  ## Network
  network_id = var.network_id

  ## Saltmaster
  saltmaster_id        = var.saltmaster_id
  saltmaster_ip        = var.saltmaster_ip
  saltmaster_public_ip = var.saltmaster_public_ip

  ## SSH
  ssh_key     = var.ssh_key
  private_key = var.private_key

  ## Cloudflare
  dns_zone = var.dns_zone
}


