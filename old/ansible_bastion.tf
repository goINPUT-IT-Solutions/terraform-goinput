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

resource "random_password" "bastion_root_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "hcloud_server" "bastion" {
    name        = "${var.bastion-server-name}.${var.domain}"
    image       = "ubuntu-20.04"
    server_type = local.hetzner_servertype["bastion"]
    location    = var.hetzner_locations[0]

    backups     = true 

    ssh_keys    =  [
        hcloud_ssh_key.default.id
    ]

    labels = {
        type = "ansible"
    }

    #user_data = file("./cloud-init/ansible.yml")


    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get upgrade -y",
            "sudo apt-get install -f software-properties-common",
            "sudo add-apt-repository --yes --update ppa:ansible/ansible",
            "sudo apt-get install -f ansible",
            "echo Done!"
        ]
    
        connection {
            host        = self.ipv4_address
            type        = "ssh"
            user        = "root"
            private_key = file(var.ssh_key)
        }
    }

    #provisioner "local-exec" {
    #    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' create-webservice.yml"
    #}
}

resource "netcup-ccp_dns_record" "bastion_dnsv4" {
  domain_name   = var.domain
  name          = "${var.bastion-server-name}"
  type          = "A"
  value         = hcloud_server.bastion.ipv4_address
  priority      = "0"               # for MX records
  depends_on = [
    hcloud_server.bastion
  ]
}

resource "netcup-ccp_dns_record" "bastion_dnsv6" {
  domain_name   = var.domain
  name          = "${var.bastion-server-name}"
  type          = "AAAA"
  value         = hcloud_server.bastion.ipv6_address
  priority      = "0"               # for MX records
  depends_on = [
    hcloud_server.bastion
  ]
}

resource "hcloud_rdns" "bastion_ipv4_rdns" {
  server_id  = hcloud_server.bastion.id
  ip_address = hcloud_server.bastion.ipv4_address
  dns_ptr    = hcloud_server.bastion.name
}

resource "hcloud_rdns" "bastion_ipv6_rdns" {
  server_id  = hcloud_server.bastion.id
  ip_address = hcloud_server.bastion.ipv6_address
  dns_ptr    = hcloud_server.bastion.name
}


output "Bastion_IPv4" {
    value = hcloud_server.bastion.ipv4_address
}

output "Bastion_IPv6" {
    value = hcloud_server.bastion.ipv6_address
}

output "Bastion_Hostname" {
    value = hcloud_server.bastion.name
}
output "Bastion_RootPassword" {
    value = hcloud_server.bastion.name
}