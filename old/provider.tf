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

terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.32"
    }

    netcup-ccp = {
        source = "rincedd/netcup-ccp"
    }

  }
}

provider "netcup-ccp" {
    customer_number  = var.netcup_customer_id   # Netcup customer number
    ccp_api_key      = var.netcup_ccp_api_key   # API key for Netcup CCP
    ccp_api_password = var.netcup_ccp_api_pw    # API key password
}

provider "hcloud" {
    token   = var.hetzner_token
}

