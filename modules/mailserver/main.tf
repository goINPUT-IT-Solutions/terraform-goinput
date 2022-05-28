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
### Names and passwords
##############################

resource "random_pet" "mailserver_names" {
  length = 1
}

resource "random_password" "mailserver_random_root_pw" {
  length  = 64
  special = false
}

resource "random_password" "mailserver_random_mailcow_pw" {
  length  = 64
  special = false
}

##############################
### Mailserver
##############################

resource "hcloud_server" "mailserver" {
  name        = "${random_pet.mailserver_names.id}.${var.service_name}.${var.environment}.${var.domain}"
  image       = "ubuntu-22.04"
  server_type = "cx31"

  ssh_keys = [
    "${var.terraform_ssh_key_id}",
    "${var.terraform_private_ssh_key_id}"
  ]
  location = "fsn1"

  firewall_ids = [
    var.firewall_default_id,
    var.firewall_mailserver_id
  ]
}

resource "hcloud_server_network" "mailserver_network" {
  server_id  = hcloud_server.mailserver.id
  network_id = var.network_webservice_id
}

resource "hcloud_volume_attachment" "log_volume" {
  volume_id = hcloud_volume.log_volume.id
  server_id = hcloud_server.mailserver.id
}

resource "hcloud_volume_attachment" "mail_volume" {
  volume_id = hcloud_volume.mail_volume.id
  server_id = hcloud_server.mailserver.id
}

##############################
### DNS ENTRIES
##############################

# Currently not in use for staging
/*module "dns_zones" {
  for_each = var.domains_zone_id

  source = "./modules/dns_entries"

  # Variables
  zone_id             = each.key
  mailserver_hostname = hcloud_server.mailserver.name
}*/

##############################
### MAILSERVER CONFIG
##############################

resource "null_resource" "mailserver_config" {

  depends_on = [
    hcloud_server.mailserver
  ]

  triggers = {
    saltmaster_public_ip = var.saltmaster_public_ip
    server_name          = hcloud_server.mailserver.name
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
      host        = hcloud_server.mailserver.ipv4_address
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
      host        = var.saltmaster_public_ip
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
}

##############################
### REVERSE DNS
##############################

resource "hcloud_rdns" "mailserver_rdns_ipv4" {
  server_id  = hcloud_server.mailserver.id
  ip_address = hcloud_server.mailserver.ipv4_address
  dns_ptr    = hcloud_server.mailserver.name
}

resource "hcloud_rdns" "mailserver_rdns_ipv6" {
  server_id  = hcloud_server.mailserver.id
  ip_address = hcloud_server.mailserver.ipv6_address
  dns_ptr    = hcloud_server.mailserver.name
}

##############################
### DNS
##############################

resource "cloudflare_record" "mailserver_dns_ipv4" {
  zone_id = var.cloudflare_goitservers_com_zone_id
  name    = hcloud_server.mailserver.name
  value   = hcloud_server.mailserver.ipv4_address
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "mailserver_dns_ipv6" {
  zone_id = var.cloudflare_goitservers_com_zone_id
  name    = hcloud_server.mailserver.name
  value   = hcloud_server.mailserver.ipv6_address
  type    = "AAAA"
  ttl     = 3600
}

##############################
### Bitwarden
##############################


