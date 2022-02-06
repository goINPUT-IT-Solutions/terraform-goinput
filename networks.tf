resource "hcloud_network" "goinput_internal_dns" {
  name     = "goinput-internal-dns"
  ip_range = var.ip_range_dns
}

resource "hcloud_network_subnet" "goinput_internal_dns_subnet" {
  network_id   = hcloud_network.goinput_internal_dns.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.ip_range_dns
}

resource "hcloud_network" "goinput_internal_db" {
  name     = "goinput-internal-db"
  ip_range = var.ip_range_db
}

resource "hcloud_network_subnet" "goinput_internal_db_subnet" {
  network_id   = hcloud_network.goinput_internal_db.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.ip_range_db
}

resource "hcloud_server_network" "db_network" {
  count     = var.hetzner_servercount["db_server"]
  server_id = hcloud_server.database[count.index].id
  subnet_id = hcloud_network_subnet.goinput_internal_db_subnet.id
}

