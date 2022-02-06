####################################################################
#                      _____ _   _ _____  _    _ _______           #
#                     |_   _| \ | |  __ \| |  | |__   __|          #
#            __ _  ___  | | |  \| | |__) | |  | |  | |             #
#           / _` |/ _ \ | | | . ` |  ___/| |  | |  | |             #
#          | (_| | (_) || |_| |\  | |    | |__| |  | |             #
#           \__, |\___/_____|_| \_|_|     \____/   |_|             #
#            __/ |                                                 #
#           |___/                                                  #
#                                                                  #
####################################################################


resource "hcloud_server" "database" {
    count       = var.hetzner_servercount["db_server"]
    name        = "database-server-${count.index}"
    image       = "ubuntu-20.04"
    server_type = local.hetzner_servertype["db_server"]
    location    = var.hetzner_locations[0]

    backups     = true 

    ssh_keys    =  [
        hcloud_ssh_key.default.id
    ]

    labels = {
        type = "database"
    }

    user_data = file("./cloud-init/basic.yml")


    # provisioner "remote-exec" {
    #    inline = [
    #        "echo Done!"
    #    ]
    #
    #    connection {
    #        host        = self.ipv4_address
    #        type        = "ssh"
    #        user        = "root"
    #        private_key = file(var.pvt_key)
    #    }
    #}

    #provisioner "local-exec" {
    #    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' create-webservice.yml"
    #}
}

resource "netcup-ccp_dns_record" "db_dnsv4" {
  domain_name   = "goitservers.com"
  count         = var.hetzner_servercount["db_server"]
  name          = hcloud_server.database[count.index].name
  type          = "A"
  value         = hcloud_server.database[count.index].ipv4_address
  priority      = "0"               # for MX records
}