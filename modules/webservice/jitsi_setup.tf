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

///////////////////////////////////////////////////////////
// Jitsi config
///////////////////////////////////////////////////////////
resource "null_resource" "jitsi_config" {

  depends_on = [
    hcloud_server.jitsi
  ]

  count = length(hcloud_server.jitsi)

  triggers = {
    saltmaster_public_ip = var.saltmaster_public_ip
    server_name          = hcloud_server.jitsi[count.index].name
    private_key          = var.terraform_private_ssh_key
  }

  # make the magic happen on web server
  provisioner "remote-exec" {
    inline = [

      "echo nameserver 8.8.8.8 > /etc/resolv.conf",

      "echo -e  'y\n'| ssh-keygen -b 4096 -t rsa -P '' -f /root/.ssh/id_rsa -q",

      "wget -O /tmp/bootstrap-salt.sh stable https://bootstrap.saltstack.com",
      "sh /tmp/bootstrap-salt.sh -L -X -A ${var.saltmaster_ip}",
      "echo '${self.triggers.server_name}' > /etc/salt/minion_id",
      "systemctl restart salt-minion",
      "systemctl enable salt-minion",
    ]

    connection {
      private_key = self.triggers.private_key
      host        = hcloud_server.jitsi[count.index].ipv4_address
      user        = "root"
    }
  }

  # Remove key on destruction
  provisioner "remote-exec" {
    when = destroy

    inline = [
      "salt-key -y -d '${self.triggers.server_name}'"
    ]

    connection {
      private_key = self.triggers.private_key
      host        = self.triggers.saltmaster_public_ip
      user        = "root"
    }
  }
}