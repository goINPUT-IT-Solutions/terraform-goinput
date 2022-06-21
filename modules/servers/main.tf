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

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.15.0"
    }

    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
  }
}

##############################
### Volumes
##############################

module "volumes" {
  source = "./volumes"

  count = var.server_count

  # Variables
  volumes      = var.server_volumes
  server_count = count.index+1
}

##############################
### Servers
##############################

resource "hcloud_server" "webservice_server" {
  count = var.server_count
  name  = (count.index >= 9 ? "${var.server_name}${count.index + 1}.${var.environment}.${var.domain}" : "${var.server_name}0${count.index + 1}.${var.environment}.${var.domain}")
  image = var.server_image

  server_type = var.server_type
  location    = (count.index % 2 == 0 ? "fsn1" : "nbg1")

  backups            = var.server_backup
  ssh_keys           = var.ssh_key
  labels             = var.server_labels
  placement_group_id = hcloud_placement_group.webservice_placement_group.id

  user_data = templatefile("${path.module}/cloud-init.tmpl", {
    saltmasterIP  = var.saltmaster_ip
    serverName    = (count.index >= 9 ? "${var.server_name}${count.index + 1}.${var.environment}.${var.domain}" : "${var.server_name}0${count.index + 1}.${var.environment}.${var.domain}"),
    serverVolumes = module.volumes[count.index].volume_meta
  })

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]

    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = var.private_key
    }
  }
}

resource "hcloud_server_network" "webservice_network" {
  count = length(hcloud_server.webservice_server)

  server_id  = hcloud_server.webservice_server[count.index].id
  network_id = var.network_id
}

resource "hcloud_placement_group" "webservice_placement_group" {
  name   = "${var.server_name}-placement"
  type   = "spread"
  labels = var.server_labels
}

##############################
### REVERSE DNS
##############################

resource "hcloud_rdns" "webservice_rdns_ipv4" {
  count = length(hcloud_server.webservice_server)

  server_id  = hcloud_server.webservice_server[count.index].id
  ip_address = hcloud_server.webservice_server[count.index].ipv4_address
  dns_ptr    = hcloud_server.webservice_server[count.index].name
}

resource "hcloud_rdns" "webservice_rdns_ipv6" {
  count = length(hcloud_server.webservice_server)

  server_id  = hcloud_server.webservice_server[count.index].id
  ip_address = hcloud_server.webservice_server[count.index].ipv6_address
  dns_ptr    = hcloud_server.webservice_server[count.index].name
}

##############################
### DNS
##############################

resource "cloudflare_record" "webservice_dns_ipv4" {
  count = length(hcloud_server.webservice_server)

  zone_id = var.dns_zone
  name    = hcloud_server.webservice_server[count.index].name
  value   = hcloud_server.webservice_server[count.index].ipv4_address
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "webservice_dns_ipv6" {
  count = length(hcloud_server.webservice_server)

  zone_id = var.dns_zone
  name    = hcloud_server.webservice_server[count.index].name
  value   = hcloud_server.webservice_server[count.index].ipv6_address
  type    = "AAAA"
  ttl     = 3600
}


module "dns" {
  source = "./dns"

  for_each = toset(var.domains)

  # Domain
  domain_name      = "${element(split(".", each.key), length(split(".", each.key)) - 2)}.${element(split(".", each.key), length(split(".", each.key)) - 1)}"
  domain_subdomain = trimsuffix(each.key, ".${element(split(".", each.key), length(split(".", each.key)) - 2)}.${element(split(".", each.key), length(split(".", each.key)) - 1)}")

  # Variables
  srv_count   = var.server_count > 0 ? 1 : 0
  domain_ipv4 = (length(hcloud_load_balancer.loadbalancer) > 0 ? try(hcloud_load_balancer.loadbalancer[0].ipv4, 0) : try(hcloud_server.webservice_server[0].ipv4_address, 0))
  domain_ipv6 = (length(hcloud_load_balancer.loadbalancer) > 0 ? try(hcloud_load_balancer.loadbalancer[0].ipv6, 0) : try(hcloud_server.webservice_server[0].ipv6_address, 0))
  domain_ttl  = 1800
}

##############################
### Mail DNS
##############################

module "mail_dns" {
  source = "./mail_dns"

  for_each = var.mail_domains

  # Variables
  ## Zone ID
  domain_name = each.key

  ## Mailserver Hostname
  mailserver_hostname = (length(hcloud_load_balancer.loadbalancer) > 0 ? try(hcloud_load_balancer.loadbalancer[0].name, 0) : try(hcloud_server.webservice_server[0].name, 0))

  ## Time To Live (in secounds)
  ttl = 1800
}
