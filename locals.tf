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
    files = {
      count  = 1
      type   = "cx11"
      image  = "debian-11"
      backup = false

      labels = {
        service      = "files"
        terraform    = true
        distribution = "debian-11"
      }

      domains = [
        "files.goinput.de"
      ]
    }

    mariadb = {
      count  = 1
      type   = "cx11"
      image  = "debian-11"
      backup = false

      loadbalancer_service = {
        service_1 = {
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
      }

      labels = {
        service      = "mariadb"
        terraform    = true
        distribution = "debian-11"
      }

      domains = [
        "mariadb.goinput.de"
      ]
    }

    mail = {
      count  = 1
      type   = "cx31"
      image  = "ubuntu-22.04"
      backup = false

      loadbalancer_service = {
        service_1 = {
          proxyprotocol = false
          protocol      = "tcp"
          listen_port   = 143

          health_check = {
            protocol = "tcp"
            port     = 143
            interval = 30
            timeout  = 30
            retries  = 4
          }
        }

        service_2 = {
          proxyprotocol = false
          protocol      = "tcp"
          listen_port   = 993

          health_check = {
            protocol = "tcp"
            port     = 993
            interval = 30
            timeout  = 30
            retries  = 4
          }
        }

        service_3 = {
          proxyprotocol = false
          protocol      = "tcp"
          listen_port   = 110

          health_check = {
            protocol = "tcp"
            port     = 110
            interval = 30
            timeout  = 30
            retries  = 4
          }
        }

        service_4 = {
          proxyprotocol = false
          protocol      = "tcp"
          listen_port   = 995

          health_check = {
            protocol = "tcp"
            port     = 995
            interval = 30
            timeout  = 30
            retries  = 4
          }
        }

        service_5 = {
          proxyprotocol = false
          protocol      = "tcp"
          listen_port   = 4190

          health_check = {
            protocol = "tcp"
            port     = 4190
            interval = 30
            timeout  = 30
            retries  = 4
          }
        }

        service_6 = {
          proxyprotocol = false
          protocol      = "tcp"
          listen_port   = 465

          health_check = {
            protocol = "tcp"
            port     = 465
            interval = 30
            timeout  = 30
            retries  = 4
          }
        }

        service_7 = {
          proxyprotocol = false
          protocol      = "tcp"
          listen_port   = 587

          health_check = {
            protocol = "tcp"
            port     = 587
            interval = 30
            timeout  = 30
            retries  = 4
          }
        }
      }

      labels = {
        service      = "mail"
        terraform    = true
        distribution = "ubuntu-22.04"
      }

      domains = [
        "mail.goinput.de"
      ]
    }

    apache = {
      count  = 1
      type   = "cx11"
      image  = "debian-11"
      backup = false

      loadbalancer_service = {
        service_1 = {
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
      }

      labels = {
        service      = "apache2"
        terraform    = true
        distribution = "debian-11"
      }

      domains = [
        "www.goinput.de",
        "goinput.de"
      ]
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

      domains = [
        "nextcloud.goinput.de",
        "cloud.goinput.de"
      ]
    }

    jitsi = {
      count  = 0
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
      count  = 0
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
      count  = 0
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
