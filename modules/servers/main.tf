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
### Servers
##############################

resource "hcloud_server" "webservice_server" {
  count = var.server_count
  name  = (count.index >= 9 ? "${var.server_name}${count.index + 1}.${var.environment}.${var.domain}" : "${var.server_name}0${count.index + 1}.${var.environment}.${var.domain}")
  image = var.server_image

  server_type = var.server_type
  location    = (count.index % 2 == 0 ? "fsn1" : "nbg1")

  backups = var.server_backup

  ssh_keys = var.ssh_key

  labels = var.server_labels

  placement_group_id = hcloud_placement_group.webservice_placement_group.id
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
### Configuration
##############################

resource "null_resource" "webservice_files" {
  count = length(hcloud_server.webservice_server)

  triggers = {
    serverID   = hcloud_server.webservice_server[count.index].id # Force rebuild if server id changes
    serverName = hcloud_server.webservice_server[count.index].name
    serverIP   = hcloud_server.webservice_server[count.index].ipv4_address

    saltmasterID = var.saltmaster_id
    saltmasterIP = var.saltmaster_ip

    privateKey = var.private_key

    files_install_salt_minion = templatefile("${path.root}/scripts/install-salt-minion.sh", {
      saltmasterIP = var.saltmaster_ip
      serverName   = hcloud_server.webservice_server[count.index].name
    })

    files_uninstall_salt_minion = templatefile("${path.root}/scripts/uninstall-salt-minion.sh", {
    })
  }

  # Create directories
  provisioner "remote-exec" {
    inline = [
      "mkdir -pv /root/.tf_salt",
      "chmod 0700 /root/.tf_salt"
    ]
  }

  # Upload files
  provisioner "file" {
    content     = self.triggers.files_install_salt_minion
    destination = "/root/.tf_salt/install-salt-minion.sh"
  }

  provisioner "file" {
    content     = self.triggers.files_uninstall_salt_minion
    destination = "/root/.tf_salt/uninstall-salt-minion.sh"
  }

  connection {
    private_key = self.triggers.privateKey
    host        = self.triggers.serverIP
    user        = "root"
  }
}

resource "null_resource" "webservice_setup" {
  depends_on = [
    null_resource.webservice_files,
    hcloud_server.webservice_server
  ]

  count = length(hcloud_server.webservice_server)

  triggers = {
    serverID   = hcloud_server.webservice_server[count.index].id # Force rebuild if server id changes
    serverName = hcloud_server.webservice_server[count.index].name
    serverIP   = hcloud_server.webservice_server[count.index].ipv4_address

    saltmasterID       = var.saltmaster_id
    saltmasterIP       = var.saltmaster_ip
    saltmasterPublicIP = var.saltmaster_public_ip

    privateKey = var.private_key

    # Files
    files_id = null_resource.webservice_files[count.index].id # Force rebuild if files change
  }

  provisioner "remote-exec" {
    when = create

    inline = [
      "bash /root/.tf_salt/install-salt-minion.sh"
    ]

    connection {
      private_key = self.triggers.privateKey
      host        = self.triggers.serverIP
      user        = "root"
    }

  }

  provisioner "remote-exec" {
    when = destroy

    inline = [
      "bash /root/.tf_salt/uninstall-salt-minion.sh"
    ]

    connection {
      private_key = self.triggers.privateKey
      host        = self.triggers.serverIP
      user        = "root"
    }

  }

  # Remove key on destruction
  provisioner "remote-exec" {
    when = destroy

    inline = [
      "salt-key -y -d '${self.triggers.serverName}'"
    ]

    connection {
      private_key = self.triggers.privateKey
      host        = self.triggers.saltmasterPublicIP
      user        = "root"
    }
  }
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

  # Variables
  srv_count   = var.server_count > 0 ? 1 : 0
  domain_name = each.key
  dns_zone    = var.goinputde_zone
  domain_ipv4 = (length(hcloud_load_balancer.loadbalancer) > 0 ? try(hcloud_load_balancer.loadbalancer[0].ipv4, 0) : try(hcloud_server.webservice_server[0].ipv4_address, 0))
  domain_ipv6 = (length(hcloud_load_balancer.loadbalancer) > 0 ? try(hcloud_load_balancer.loadbalancer[0].ipv6, 0) : try(hcloud_server.webservice_server[0].ipv6_address, 0))
  domain_ttl  = 1800
}

##############################
### Volumes
##############################

module "volumes" {
  source = "./volumes"

  for_each = var.server_volumes

  # Variables
  ## Count, Name, Size, Filesystem
  volume_count = length(hcloud_server.webservice_server)
  volume_name  = each.key
  volume_size  = each.value.size
  volume_fs    = each.value.fs

  ## Labels
  volume_labels = each.value.labels

  ## ServerID, ServerName
  server_name = var.server_name
  volume_serverid = [
    for server in hcloud_server.webservice_server : server.id
  ]
}