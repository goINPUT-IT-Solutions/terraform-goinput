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
### Random names and passwords
##############################


resource "random_pet" "webserver_names" {
  length = 2
  count  = var.server_count
}

##############################
### Webserver
##############################

resource "hcloud_server" "webserver" {
  count       = var.server_count
  name        = "${random_pet.webserver_names[count.index].id}.${var.service_name}.${var.environment}.${var.domain}"
  image       = "ubuntu-20.04"
  server_type = "cx11"

  ssh_keys = [
    "${var.terraform_ssh_key_id}",
    "${var.terraform_private_ssh_key_id}"
  ]
  location = "fsn1"

  firewall_ids = [
    var.firewall_default_id,
    var.firewall_webservice_id
  ]
}

resource "hcloud_server_network" "webserver_network" {
  count = length(hcloud_server.webserver)

  server_id  = hcloud_server.webserver[count.index].id
  network_id = var.network_webservice_id
}