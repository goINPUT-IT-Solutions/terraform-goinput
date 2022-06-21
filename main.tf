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
  cloud {
    organization = "goINPUT"

    workspaces {
      name = "infrastructure-main"
    }
  }

  required_providers {
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

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.15.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

##############################
### GitHub
##############################

provider "github" {
  token = var.github_token
}

##############################
### Cloudflare
##############################

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

##############################
### Hetzner
##############################

provider "hcloud" {
  token = var.hcloud_token
}

data "hcloud_ssh_key" "hcloud_terraform_ssh_key" {
  name = "Javik OpenSSH Key for Stargazer"
}

resource "tls_private_key" "terraform_private_key" {
  algorithm = "ED25519"
}

resource "hcloud_ssh_key" "terraform_private_key" {
  name       = "Terraform Private Key"
  public_key = tls_private_key.terraform_private_key.public_key_openssh
}

##############################
### Bitwarden
##############################

provider "bitwarden" {
  master_password = var.bitwarden_master_password
  client_id       = var.bitwarden_client_id
  client_secret   = var.bitwarden_client_secret
  email           = var.bitwarden_email
  server          = var.bitwarden_server
}

##############################
### Let's Encrypt
##############################

provider "acme" {
  server_url = var.acme_server_url
}

resource "tls_private_key" "acme_account_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "acme_registration" "acme_account_registration" {
  account_key_pem = tls_private_key.acme_account_private_key.private_key_pem
  email_address   = var.acme_email
}

resource "tls_private_key" "goinput_wildcard_certificate_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "goinput_wildcard_certificate_request" {
  private_key_pem = tls_private_key.goinput_wildcard_certificate_private_key.private_key_pem
  dns_names = [
    "goinput.de",
    "*.goinput.de"
  ]

  subject {
    common_name = "goinput.de"
  }
}

resource "acme_certificate" "goinput_wildcard_certificate" {
  account_key_pem         = acme_registration.acme_account_registration.account_key_pem
  certificate_request_pem = tls_cert_request.goinput_wildcard_certificate_request.cert_request_pem

  dns_challenge {
    provider = "cloudflare"

    config = {
      CF_API_EMAIL = var.cloudflare_email
      CF_API_KEY   = var.cloudflare_api_key
    }
  }
}

resource "hcloud_uploaded_certificate" "goinput_wildcard_certificate" {
  name = "goinput-wildcard"

  private_key = tls_private_key.goinput_wildcard_certificate_private_key.private_key_pem
  certificate = "${acme_certificate.goinput_wildcard_certificate.certificate_pem}${acme_certificate.goinput_wildcard_certificate.issuer_pem}"

  labels = {
    certificate = "goinput.de"
    wildcard    = true
    terraform   = true
  }
}

##############################
### goINPUT Modules
##############################

module "firewall" {
  source = "./modules/firewall"

  ###### Variables

  ##### Dependencies
}

module "networks" {
  source = "./modules/networks"

  ###### Variables

  nameserver_network_name     = "${var.nameserver_network_name}-${var.environment}"
  nameserver_network_ip_range = var.nameserver_network_ip_range

  mailserver_network_name     = "${var.mailserver_network_name}-${var.environment}"
  mailserver_network_ip_range = var.mailserver_network_ip_range

  webservice_network_name     = "${var.webservice_network_name}-${var.environment}"
  webservice_network_ip_range = var.webservice_network_ip_range

  ##### Dependencies

  depends_on = [
    module.firewall
  ]
}

module "salt" {
  source = "./modules/salt"

  ###### Variables

  // SSH
  terraform_ssh_key_id         = data.hcloud_ssh_key.hcloud_terraform_ssh_key.id
  terraform_private_ssh_key_id = hcloud_ssh_key.terraform_private_key.id
  terraform_private_ssh_key    = tls_private_key.terraform_private_key.private_key_openssh

  domain      = var.domain
  environment = var.environment

  // FIREWALLS
  firewall_default_id     = module.firewall.firewall_default_id
  firewall_saltbastion_id = module.firewall.firewall_saltbastion_id

  // Networks
  network_webservice_id = module.networks.webservice_network_id

  // Cloudflare
  cloudflare_email                   = var.cloudflare_email
  cloudflare_api_key                 = var.cloudflare_api_key
  cloudflare_goitservers_com_zone_id = data.cloudflare_zone.dns_zones[var.domain].zone_id

  // SaltServers
  salt_servers = local.servers

  ##### Dependencies

  depends_on = [
    module.firewall,
    module.networks
  ]
}

module "servers" {
  source = "./modules/servers"

  for_each = local.servers

  # Variables
  ## Server name and count
  server_name   = each.key
  server_count  = try(each.value.count, 0)
  server_type   = try(each.value.type, "cx11")
  server_image  = try(each.value.image, "debian-11")
  server_backup = try(each.value.backup, false)
  server_labels = try(each.value.labels, "")

  ## Domain and environment
  domain      = var.domain
  environment = var.environment

  # Mails
  mail_domains = (each.key == "mail" ? each.value.mail_domains : [])

  ## Network
  network_id = module.networks.webservice_network_id

  ## Volumes
  server_volumes = try(each.value.volumes, {})

  ## Saltmaster
  saltmaster_id        = module.salt.saltstack_id
  saltmaster_ip        = module.salt.saltstack_webservice_network_ip
  saltmaster_public_ip = module.salt.saltstack_public_ipv4

  ## Loadbalancer
  loadbalancer_services = try(each.value.loadbalancer_service, {})

  ## SSH
  ssh_key = [
    hcloud_ssh_key.terraform_private_key.id,
    data.hcloud_ssh_key.hcloud_terraform_ssh_key.id
  ]
  private_key = tls_private_key.terraform_private_key.private_key_openssh

  ## Domains
  domains = try(each.value.domains, [])

  ## Cloudflare and Let's Encrypt
  goinputde_zone         = data.cloudflare_zone.goinput_de.zone_id
  dns_zone               = data.cloudflare_zone.dns_zones[var.domain].zone_id
  cloudflare_email       = var.cloudflare_email
  cloudflare_api_key     = var.cloudflare_api_key
  acme_account_key       = acme_registration.acme_account_registration.account_key_pem
  goinput_certificate_id = hcloud_uploaded_certificate.goinput_wildcard_certificate.id

  depends_on = [
    module.firewall,
    module.networks,
    module.salt,
    hcloud_uploaded_certificate.goinput_wildcard_certificate
  ]
}
