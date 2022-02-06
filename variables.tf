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

variable "hetzner_token" {
  sensitive = true
  type      = string
}

variable "ssh_key" {
    type = string
}

variable "hetzner_locations" {
    type = list(string)
    default = [
        "fsn1",
        "nbg1",
        "hel1",
        "ash"
    ]
}

variable "hetzner_servercount" {
    type = map
}

variable "hetzner_servertypes" {
    type = list(string)
    default = [
        # vServers
        "cx11",     # 1 vCPUs,  2 GB RAM,   20 GB SSD,  20 TB Traffic, Price / H 0,007 € /h, Price  4,15 € / mo
        "cpx11",    # 2 vCPUs,  2 GB RAM,   40 GB SSD,  20 TB Traffic, Price / H 0,008 € /h, Price  4,75 € / mo
        "cx21",     # 2 vCPUs,  4 GB RAM,   40 GB SSD,  20 TB Traffic, Price / H 0,010 € /h, Price  5,83 € / mo
        "cpx21",    # 3 vCPUs,  4 GB RAM,   80 GB SSD,  20 TB Traffic, Price / H 0,013 € /h, Price  8,21 € / mo
        "cx31",     # 2 vCPUs,  8 GB RAM,   80 GB SSD,  20 TB Traffic, Price / H 0,017 € /h, Price 10,59 € / mo
        "cpx31",    # 4 vCPUs,  8 GB RAM,   160 GB SSD, 20 TB Traffic, Price / H 0,024 € /h, Price 14,76 € / mo
        "cx41",     # 4 vCPUs,  16 GB RAM,  160 GB SSD, 20 TB Traffic, Price / H 0,031 € /h, Price 18,92 € / mo
        "cpx41",    # 8 vCPUs,  16 GB RAM,  240 GB SSD, 20 TB Traffic, Price / H 0,045 € /h, Price 27,25 € / mo
        "cx51",     # 8 vCPUs,  32 GB RAM,  240 GB SSD, 20 TB Traffic, Price / H 0,060 € /h, Price 35,58 € / mo
        "cpx51",    # 16 vCPUs, 32 GB RAM,  360 GB SSD, 20 TB Traffic, Price / H 0,095 € /h, Price 59,38 € / mo

        # vServers with dedicated CPUs
        "ccx11",
        "ccx12",
        "ccx21",
        "ccx22",
        "ccx31",
        "ccx32",
        "ccx41",
        "ccx42",
        "ccx51",
        "ccx52",
        "ccx62"
    ]
}

variable "ip_range_dns" {
    default = "192.168.100.0/24"
    type = string
}

variable "ip_range_db" {
    default = "192.168.110.0/24"
    type = string
}

variable "ip_range_internal_1" {
    default = "192.168.120.0/24"
    type = string
}

variable "db-server-name" {
  default = "db"
  type = string
}

variable "bastion-server-name" {
  default = "bastion"
  type = string
}

variable "domain" {
  default = "goitservers.com"
    type = string
}

variable "netcup_customer_id" {
    type = string
    sensitive = true
}
variable "netcup_ccp_api_key" {
    type = string
    sensitive = true
}
variable "netcup_ccp_api_pw" {
    type = string
    sensitive = true
}
