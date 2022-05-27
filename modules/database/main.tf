terraform {
  required_providers {
    powerdns = {
      source  = "pan-net/powerdns"
      version = "~> 1.5"
    }

    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
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
  length = 2
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

  ssh_keys = ["${var.terraform_ssh_key_id}"]
  location = "fsn1"

  network {
    network_id = var.network_webservice_id
  }

  firewall_ids = [
    var.firewall_default_id
  ]
}


///////////////////////////////////////////////////////////
// Database config
///////////////////////////////////////////////////////////
resource "null_resource" "database_config" {

  depends_on = [
    hcloud_server.database
  ]

  count = length(hcloud_server.database)

  triggers = {
    saltmaster_public_ip = var.saltmaster_public_ip
    server_name          = hcloud_server.database[count.index].name
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
      private_key = file(abspath("${path.root}/keys/terraform_ssh_key"))
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
      private_key = file(abspath("${path.root}/keys/terraform_ssh_key"))
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
      private_key = file(abspath("${path.root}/keys/terraform_ssh_key"))
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

