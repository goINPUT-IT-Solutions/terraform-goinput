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
    name        = "${var.db-server-name}${count.index+1}.${var.domain}"
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

    depends_on = [
      hcloud_network.goinput_internal_db,
      hcloud_network_subnet.goinput_internal_db_subnet,
      hcloud_server.bastion
    ]

    #provisioner "local-exec" {
    #    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' create-webservice.yml"
    #}
}

resource "hcloud_rdns" "dns_ipv4_rdns" {
  count      = var.hetzner_servercount["db_server"]
  server_id  = hcloud_server.database[count.index].id
  ip_address = hcloud_server.database[count.index].ipv4_address
  dns_ptr    = hcloud_server.database[count.index].name
}

resource "hcloud_rdns" "dns_ipv6_rdns" {
  count      = var.hetzner_servercount["db_server"]
  server_id  = hcloud_server.database[count.index].id
  ip_address = hcloud_server.database[count.index].ipv6_address
  dns_ptr    = hcloud_server.database[count.index].name
}

resource "netcup-ccp_dns_record" "db_dnsv4" {
  domain_name   = var.domain
  count         = var.hetzner_servercount["db_server"]
  name          = "${var.db-server-name}${count.index+1}"
  type          = "A"
  value         = hcloud_server.database[count.index].ipv4_address
  priority      = "0"               # for MX records
  depends_on = [
    hcloud_server.database,
    hcloud_network.goinput_internal_db,
    hcloud_network_subnet.goinput_internal_db_subnet
  ]
}

resource "netcup-ccp_dns_record" "db_dnsv6" {
  domain_name   = var.domain
  count         = var.hetzner_servercount["db_server"]
  name          = "${var.db-server-name}${count.index+1}"
  type          = "AAAA"
  value         = hcloud_server.database[count.index].ipv6_address
  priority      = "0"               # for MX records
  depends_on = [
    hcloud_server.database,
    hcloud_network.goinput_internal_db,
    hcloud_network_subnet.goinput_internal_db_subnet
  ]
}
