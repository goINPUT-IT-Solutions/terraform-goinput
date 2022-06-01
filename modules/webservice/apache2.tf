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

##############################
### Apache2 Server
##############################

resource "hcloud_server" "apache" {
  count       = var.apache_count
  name        = (count.index >= 9 ? "apache${count.index + 1}.${var.environment}.${var.domain}" : "apache0${count.index + 1}.${var.environment}.${var.domain}")
  image       = "debian-11"
  server_type = "cx11"

  ssh_keys = [
    "${var.terraform_ssh_key_id}",
    "${var.terraform_private_ssh_key_id}"
  ]

  location = (count.index % 2 == 0 ? "fsn1" : "nbg1")

  firewall_ids = [
    var.firewall_default_id,
    var.firewall_webservice_id
  ]
}

resource "hcloud_server_network" "apache_network" {
  count = length(hcloud_server.apache)

  server_id  = hcloud_server.apache[count.index].id
  network_id = var.network_webservice_id
}
