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
      count  = 0
      type   = "cx11"
      image  = local.distro.debian
      backup = false

      labels = {
        service      = "files"
        terraform    = true
        distribution = local.distro.debian
      }

      domains = [
        "files.goinput.de"
      ]

      volumes = {
        www-data = {
          size    = 10
          fs      = "ext4"
          mount   = "/media/wwwdata"
          systemd = "media-wwwdata.mount"

          labels = {
            data      = "Websites"
            terraform = true
          }
        }
        log-data = {
          size    = 10
          fs      = "ext4"
          mount   = "/var/log"
          systemd = "var-log.mount"

          labels = {
            data      = "Logs"
            terraform = true
          }
        }
      }
    }

    minio = {
      count  = 1
      type   = "cx11"
      image  = local.distro.debian
      backup = false

      labels = {
        service      = "minio"
        terraform    = true
        distribution = local.distro.debian
      }

      domains = [
        "minio.goinput.de"
      ]

      volumes = {
        data01-drive = {
          size    = 20
          fs      = "ext4"
          mount   = "/media/data01"
          systemd = "media-data01.mount"

          labels = {
            data      = "Websites"
            terraform = true
          }
        }

        data02-drive = {
          size    = 20
          fs      = "ext4"
          mount   = "/media/data02"
          systemd = "media-data02.mount"

          labels = {
            data      = "Websites"
            terraform = true
          }
        }

        log-data = {
          size    = 10
          fs      = "ext4"
          mount   = "/var/log"
          systemd = "var-log.mount"

          labels = {
            data      = "Logs"
            terraform = true
          }
        }
      }
    }

    mariadb = {
      count  = 1
      type   = "cx11"
      image  = local.distro.debian
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
        distribution = local.distro.debian
      }

      domains = [
        "mariadb.goinput.de"
      ]

      volumes = {
        log-data = {
          size    = 10
          fs      = "ext4"
          mount   = "/var/log"
          systemd = "var-log.mount"

          labels = {
            data      = "Logs"
            terraform = true
          }
        }
      }
    }

    mail = {
      count  = 1
      type   = "cx31"
      image  = local.distro.ubuntu
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
        distribution = local.distro.ubuntu
      }


      domains = [
      ]

      mail_domains = var.domains

      volumes = {
        log-data = {
          size    = 10
          fs      = "ext4"
          mount   = "/var/log"
          systemd = "var-log.mount"

          labels = {
            data      = "Logs"
            terraform = true
          }
        }
      }
    }

    apache = {
      count  = 1
      type   = "cx11"
      image  = local.distro.debian
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
        distribution = local.distro.debian
      }

      domains = [
        "www.goinput.de",
        "goinput.de"
      ]

      volumes = {
        log-data = {
          size    = 10
          fs      = "ext4"
          mount   = "/var/log"
          systemd = "var-log.mount"

          labels = {
            data      = "Logs"
            terraform = true
          }
        }
      }
    }

    nextcloud = {
      count  = 0
      type   = "cx21"
      image  = local.distro.ubuntu
      backup = true

      labels = {
        service      = "nextcloud"
        terraform    = true
        distribution = local.distro.ubuntu
      }

      domains = [
        "nextcloud.goinput.de",
        "cloud.goinput.de"
      ]

      volumes = {
        log-data = {
          size    = 10
          fs      = "ext4"
          mount   = "/var/log"
          systemd = "var-log.mount"

          labels = {
            data      = "Logs"
            terraform = true
          }
        }
      }
    }

    jitsi = {
      count  = 0
      type   = "cx21"
      image  = local.distro.ubuntu
      backup = false

      labels = {
        service      = "jitsi"
        terraform    = true
        distribution = local.distro.ubuntu
      }

      volumes = {
        log-data = {
          size    = 10
          fs      = "ext4"
          mount   = "/var/log"
          systemd = "var-log.mount"

          labels = {
            data      = "Logs"
            terraform = true
          }
        }
      }
    }

    wireguard = {
      count  = 1
      type   = "cx11"
      image  = local.distro.debian
      backup = false

      labels = {
        service      = "wireguard"
        terraform    = true
        distribution = local.distro.debian
      }

      volumes = {
        log-data = {
          size    = 10
          fs      = "ext4"
          mount   = "/var/log"
          systemd = "var-log.mount"

          labels = {
            data      = "Logs"
            terraform = true
          }
        }
      }
    }

    bitwarden = {
      count  = 0
      type   = "cx11"
      image  = local.distro.debian
      backup = false

      labels = {
        service      = "bitwarden"
        terraform    = true
        distribution = local.distro.debian
      }

      volumes = {
        log-data = {
          size    = 10
          fs      = "ext4"
          mount   = "/var/log"
          systemd = "var-log.mount"

          labels = {
            data      = "Logs"
            terraform = true
          }
        }
      }
    }
  }
}
