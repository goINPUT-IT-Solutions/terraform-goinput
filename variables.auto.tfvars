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
### Hetzner
##############################

hcloud_token                = "CwpNm1cJbERFjfh0pItutXhzW0t9mntz8u5QSVjyC0EOHjQ4uxDEECSzIsxhYGzd"
nameserver_network_name     = "Nameserver Network"
nameserver_network_ip_range = "10.0.1.0/24"

mailserver_network_name     = "Mailserver Network"
mailserver_network_ip_range = "10.0.2.0/24"

webservice_network_name     = "Webservice Network"
webservice_network_ip_range = "10.0.3.0/24"

##############################
### Bitwarden
##############################

bitwarden_master_password = "MWM1YjBlMmY0Zjc5MGJmNjExZDg5ZjY1"
bitwarden_client_id       = "user.c669e2d0-29ff-4a24-bdce-de95e349b3a8"
bitwarden_client_secret   = "7AtwIfftM2sxiMb1LZKHwzttiAYPtr"
bitwarden_email           = "terraform@goinput.de"
bitwarden_server          = "https://vault.goinput.de"

##############################
### Defaults
##############################

terraform_ssh_key = "keys/terraform_ssh_key"
