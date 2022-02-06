locals {
    hetzner_servertype = {
        dns_server            = var.hetzner_servertypes[0],
        db_server             = var.hetzner_servertypes[0],
        communications_server = var.hetzner_servertypes[0],
        web_server            = var.hetzner_servertypes[0]
    }
}