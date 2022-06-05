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
### Server configuration
##############################

locals {
  servers = {
    mariadb = {
      count  = 3
      type   = "cx11"
      image  = "debian-11"
      backup = false

      loadbalancer_service = {
        proxyprotocol = false
        protocol      = "tcp"
        listen_port   = 3306

        health_check = {
          protocol = "tcp"
          port     = 3306
          interval = 30
          timeout  = 30
          retries  = 4
        }
      }

      labels = {
        service      = "mariadb"
        terraform    = true
        distribution = "debian-11"
      }
    }

    mail = {
      count  = 3
      type   = "cx31"
      image  = "ubuntu-22.04"
      backup = false

      labels = {
        service      = "mail"
        terraform    = true
        distribution = "ubuntu-22.04"
      }
    }

    apache = {
      count  = 3
      type   = "cx11"
      image  = "debian-11"
      backup = false

      loadbalancer_service = {
        proxyprotocol    = false
        protocol         = "https"
        listen_port      = 443
        destination_port = 80

        health_check = {
          protocol = "http"
          port     = 80
          interval = 5
          timeout  = 5
          retries  = 4

          http = {
            tls = false
          }
        }
      }

      labels = {
        service      = "apache2"
        terraform    = true
        distribution = "debian-11"
      }
    }

    nextcloud = {
      count  = 1
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
      count  = 1
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
      count  = 1
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
      count  = 1
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
}
