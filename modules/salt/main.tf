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

    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }

    gpg = {
      source  = "Olivr/gpg"
      version = "0.2.1"
    }
  }
}

##############################
### GPG Private Key
##############################

resource "gpg_private_key" "saltbastion_secure_key" {
  name     = hcloud_server.saltbastion.name
  email    = "admin@goinput.de"
  rsa_bits = 4096
}

##############################
### Salt Bastion server
##############################

resource "hcloud_server" "saltbastion" {
  name        = "salt01.${var.environment}.${var.domain}"
  image       = "ubuntu-20.04"
  server_type = "cx21"

  labels = {
    distribution = "ubuntu-20.04"
    service      = "salt-master"
    terraform    = true
  }

  ssh_keys = [
    "${var.terraform_ssh_key_id}",
    "${var.terraform_private_ssh_key_id}"
  ]
  location = "fsn1"

  firewall_ids = [
    var.firewall_default_id,
    var.firewall_saltbastion_id
  ]
}

resource "hcloud_server_network" "saltbastion_webserive_network" {
  server_id  = hcloud_server.saltbastion.id
  network_id = var.network_webservice_id
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

resource "cloudflare_record" "saltbastion_dns_ipv4" {
  zone_id = var.cloudflare_goitservers_com_zone_id
  name    = hcloud_server.saltbastion.name
  value   = hcloud_server.saltbastion.ipv4_address
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "saltbastion_dns_ipv6" {
  zone_id = var.cloudflare_goitservers_com_zone_id
  name    = hcloud_server.saltbastion.name
  value   = hcloud_server.saltbastion.ipv6_address
  type    = "AAAA"
  ttl     = 3600
}

##############################
### Bitwarden
##############################

##############################
### GitHub
##############################

/*data "github_repository" "goinput-terraform" {
  full_name = "goINPUT-IT-Solutions/terraform-goinput"
}

output "test" {
  value = data.github_repository.goinput-terraform.name
}

resource "github_repository_webhook" "goinput-terraform_salt_hook" {
  repository = "goINPUT-IT-Solutions/terraform-goinput"

  configuration {
    url          = "https://${hcloud_server.saltbastion.name}/hook/github"
    content_type = "json"
    insecure_ssl = false
  }

  active = true

  events = ["push"]
}*/
