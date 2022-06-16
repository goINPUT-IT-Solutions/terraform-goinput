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
### Loadbalancer Service
##############################

### TCP

resource "hcloud_load_balancer_service" "loadbalancer_service_tcp" {
  count            = (var.loadbalancer_protocol == "tcp" ? var.loadbalancer_count : 0)

  load_balancer_id = var.loadbalancer_id[count.index]
  protocol         = var.loadbalancer_protocol
  proxyprotocol    = var.loadbalancer_proxyprotocol
  listen_port      = var.loadbalancer_listen_port
  destination_port = var.loadbalancer_destination_port

  health_check {
    protocol = var.loadbalancer_hc_protocol
    port     = var.loadbalancer_hc_port
    interval = var.loadbalancer_hc_interval
    timeout  = var.loadbalancer_hc_timeout
    retries  = var.loadbalancer_hc_retries
  }
}

### HTTPS

resource "hcloud_load_balancer_service" "loadbalancer_service_https" {
  count            = (var.loadbalancer_protocol == "https" ? var.loadbalancer_count : 0)

  load_balancer_id = var.loadbalancer_id[count.index]
  protocol         = var.loadbalancer_protocol
  proxyprotocol    = var.loadbalancer_proxyprotocol
  listen_port      = var.loadbalancer_listen_port
  destination_port = var.loadbalancer_destination_port

  http {
    certificates  = (var.loadbalancer_protocol == "https" ? [var.loadbalancer_certificate_id[count.index], var.goinput_certificate_id] : [])
    redirect_http = (var.loadbalancer_protocol == "https" ? true : false)
  }

  health_check {
    protocol = var.loadbalancer_hc_protocol
    port     = var.loadbalancer_hc_port
    interval = var.loadbalancer_hc_interval
    timeout  = var.loadbalancer_hc_timeout
    retries  = var.loadbalancer_hc_retries

    http {
      domain       = var.loadbalancer_hc_http_domain
      path         = var.loadbalancer_hc_http_path
      response     = var.loadbalancer_hc_http_response
      tls          = var.loadbalancer_hc_http_tls
      status_codes = var.loadbalancer_hc_http_status_codes
    }
  }
}

resource "hcloud_load_balancer_service" "loadbalancer_service_http" {
  count            = (var.loadbalancer_protocol == "http" ? try(var.loadbalancer_count, 0) : 0)

  load_balancer_id = var.loadbalancer_id[count.index]
  protocol         = var.loadbalancer_protocol
  proxyprotocol    = var.loadbalancer_proxyprotocol
  listen_port      = var.loadbalancer_listen_port
  destination_port = var.loadbalancer_destination_port

  health_check {
    protocol = var.loadbalancer_hc_protocol
    port     = var.loadbalancer_hc_port
    interval = var.loadbalancer_hc_interval
    timeout  = var.loadbalancer_hc_timeout
    retries  = var.loadbalancer_hc_retries

    http {
      domain       = var.loadbalancer_hc_http_domain
      path         = var.loadbalancer_hc_http_path
      response     = var.loadbalancer_hc_http_response
      tls          = false
      status_codes = var.loadbalancer_hc_http_status_codes
    }
  }
}
