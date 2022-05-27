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
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.15.0"
    }

    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.33.2"
    }

    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "~> 0.2.0"
    }
  }
}

##############################
### Random names and passwords
##############################

resource "random_pet" "database_names" {
  length = 1
  count  = var.server_count
}

##############################
### Database Server
##############################

resource "hcloud_server" "database" {
  count       = var.server_count
  name        = "${random_pet.database_names[count.index].id}.${var.service_name}.${var.domain}"
  image       = "ubuntu-20.04"
  server_type = "cx11"

  ssh_keys = [
    "${var.terraform_ssh_key_id}",
    "${var.terraform_private_ssh_key_id}",
  ]
  location = "fsn1"

  network {
    network_id = var.network_webservice_id
  }

  firewall_ids = [
    var.firewall_default_id
  ]
}


##############################
### Database Config
##############################
resource "null_resource" "database_config" {

  depends_on = [
    hcloud_server.database
  ]

  count = length(hcloud_server.database)

  triggers = {
    saltmaster_public_ip = var.saltmaster_public_ip
    server_name          = hcloud_server.database[count.index].name
    private_key          = var.terraform_private_ssh_key
  }

  # make the magic happen on web server
  provisioner "remote-exec" {
    inline = [

      "echo nameserver 8.8.8.8 > /etc/resolv.conf",

      "echo -e  'y\n'| ssh-keygen -b 4096 -t rsa -P '' -f /root/.ssh/id_rsa -q",

      "wget -O /tmp/bootstrap-salt.sh https://bootstrap.saltstack.com",
      "sh /tmp/bootstrap-salt.sh -L -X -A ${var.saltmaster_ip}",
      "echo '${self.triggers.server_name}' > /etc/salt/minion_id",
      "systemctl restart salt-minion",
      "systemctl enable salt-minion",
    ]

    connection {
      private_key = self.triggers.private_key
      host        = hcloud_server.database[count.index].ipv4_address
      user        = "root"
    }
  }

  # Accept minion key on master
  provisioner "remote-exec" {
    inline = [
      "salt-key -y -a '${self.triggers.server_name}'"
    ]

    connection {
      private_key = self.triggers.private_key
      host        = self.triggers.saltmaster_public_ip
      user        = "root"
    }
  }

  # delete minion key on master when destroying
  provisioner "remote-exec" {
    when = destroy

    inline = [
      "salt-key -y -d '${self.triggers.server_name}'",
    ]

    connection {
      private_key = self.triggers.private_key
      host        = self.triggers.saltmaster_public_ip
      user        = "root"
    }
  }

  # delete host from local hosts file when destroying
  /*provisioner "local-exec" {
    when    = "destroy"
    command = "sed -i '' '/${element(hcloud_server.webserver.*.name, count.index)}/d' salt/srv/salt/common/hosts"
  }*/
}

##############################
### REVERSE DNS
##############################

resource "hcloud_rdns" "database_rdns_ipv4" {
  count = length(hcloud_server.database)

  server_id  = hcloud_server.database[count.index].id
  ip_address = hcloud_server.database[count.index].ipv4_address
  dns_ptr    = hcloud_server.database[count.index].name
}

resource "hcloud_rdns" "database_rdns_ipv6" {
  count = length(hcloud_server.database)

  server_id  = hcloud_server.database[count.index].id
  ip_address = hcloud_server.database[count.index].ipv6_address
  dns_ptr    = hcloud_server.database[count.index].name
}

##############################
### DNS
##############################

resource "cloudflare_record" "database_dns_ipv4" {
  count = length(hcloud_server.database)

  zone_id = var.cloudflare_goitservers_com_zone_id
  name    = hcloud_server.database[count.index].name
  value   = hcloud_server.database[count.index].ipv4_address
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "database_dns_ipv6" {
  count = length(hcloud_server.database)

  zone_id = var.cloudflare_goitservers_com_zone_id
  name    = hcloud_server.database[count.index].name
  value   = hcloud_server.database[count.index].ipv6_address
  type    = "AAAA"
  ttl     = 3600
}


