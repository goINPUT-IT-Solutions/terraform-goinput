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
### Required providers
##############################

terraform {
  required_providers {
    powerdns = {
      source  = "pan-net/powerdns"
      version = "~> 1.5"
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

resource "random_pet" "saltbastion_name" {
  length = 2
}

##############################
### Salt Bastion server
##############################

resource "hcloud_server" "saltbastion" {
  name        = "${random_pet.saltbastion_name.id}.${var.service_name}.${var.domain}"
  image       = "ubuntu-20.04"
  server_type = "cx21"

  ssh_keys = ["${var.terraform_ssh_key_id}"]
  location = "fsn1"

  network {
    network_id = var.network_webservice_id
  }

  firewall_ids = [
    var.firewall_default_id
  ]
}

##############################
### Salt master config
##############################

resource "null_resource" "saltmaster_config" {
  depends_on = [
    hcloud_server.saltbastion
  ]

  triggers = {
    saltmasterid = "${hcloud_server.saltbastion.id}"
  }

  connection {
    private_key = file(abspath("${path.root}/keys/terraform_ssh_key"))
    host        = hcloud_server.saltbastion.ipv4_address
    user        = "root"
  }

  # make the magic happen on salt master
  provisioner "remote-exec" {
    inline = [
      "echo master > /etc/hostname",
      "hostnamectl set-hostname master --static",
      "hostnamectl set-hostname master --pretty",
      "hostnamectl set-hostname master --transient",
      "echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf",
      "sysctl -p",

      "echo '127.0.0.1 salt master' >> /etc/hosts",
      "echo -e  'y\n'| ssh-keygen -b 4096 -t rsa -P '' -f /root/.ssh/id_rsa -q",
      "wget -O /tmp/bootstrap-salt.sh https://bootstrap.saltstack.com",
      "sh /tmp/bootstrap-salt.sh -M -L -X -A master",
      "mkdir -p /etc/salt/pki/master/minions",
      "salt-key --gen-keys=minion --gen-keys-dir=/etc/salt/pki/minion",
      "cp /etc/salt/pki/minion/minion.pub /etc/salt/pki/master/minions/master",
      "mkdir /srv/salt",

      "systemctl start salt-master",
      "systemctl start salt-minion",
      "systemctl enable salt-master",
      "systemctl enable salt-minion",
      "sleep 10",
      "salt '*' test.ping",
    ]
  }
}

##############################
### REVERSE DNS
##############################

resource "hcloud_rdns" "saltbastion_rdns_ipv4" {
  server_id  = hcloud_server.saltbastion.id
  ip_address = hcloud_server.saltbastion.ipv4_address
  dns_ptr    = hcloud_server.saltbastion.name
}

resource "hcloud_rdns" "saltbastion_rdns_ipv6" {
  server_id  = hcloud_server.saltbastion.id
  ip_address = hcloud_server.saltbastion.ipv6_address
  dns_ptr    = hcloud_server.saltbastion.name
}

##############################
### DNS
##############################

##############################
### Bitwarden
##############################