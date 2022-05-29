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
### Salt master config
##############################

resource "null_resource" "saltmaster_files" {
  depends_on = [
    hcloud_server.saltbastion
  ]

  triggers = {
    saltmasterid = "${hcloud_server.saltbastion.id}"
    saltmasterip = hcloud_server.saltbastion.ipv4_address
    private_key  = var.terraform_private_ssh_key
  }

  provisioner "file" {
    source      = "${path.root}/scripts/install-salt-master.sh"
    destination = "/tmp/install-salt-master.sh"
  }

  provisioner "file" {
    source      = "${path.root}/scripts/setup-git-hook.sh"
    destination = "/tmp/setup-git-hook.sh"
  }

  connection {
    private_key = self.triggers.private_key
    host        = self.triggers.saltmasterip
    user        = "root"
  }
}

resource "null_resource" "saltmaster_config" {
  depends_on = [
    hcloud_server.saltbastion,
    null_resource.saltmaster_files
  ]

  triggers = {
    saltmasterid = "${hcloud_server.saltbastion.id}"
    saltmasterip = hcloud_server.saltbastion.ipv4_address
    server_name  = hcloud_server.saltbastion.name
    private_key  = var.terraform_private_ssh_key
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-salt-master.sh",
      "/tmp/install-salt-master.sh",
      "chmod +x /tmp/setup-git-hook.sh",
      "/tmp/setup-git-hook.sh"
    ]
  }

  connection {
    private_key = self.triggers.private_key
    host        = self.triggers.saltmasterip
    user        = "root"
  }

  # Accept minion key on master
  provisioner "remote-exec" {
    inline = [
      "salt-key -y -a '${self.triggers.server_name}'"
    ]

    connection {
      private_key = self.triggers.private_key
      host        = self.triggers.saltmasterip
      user        = "root"
    }
  }

  # make the magic happen on salt master
  /*provisioner "remote-exec" {
    inline = [
      "apt-get install git -y",
      "echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf",
      "sysctl -p",

      "echo '127.0.0.1 salt master' >> /etc/hosts",
      "echo -e  'y\n'| ssh-keygen -b 4096 -t rsa -P '' -f /root/.ssh/id_rsa -q",
      "wget -O /tmp/bootstrap-salt.sh https://bootstrap.saltstack.com",
      "sh /tmp/bootstrap-salt.sh -M -L -X -A master",
      "mkdir -p /etc/salt/pki/master/minions",
      "salt-key --gen-keys=minion --gen-keys-dir=/etc/salt/pki/minion",
      "cp /etc/salt/pki/minion/minion.pub /etc/salt/pki/master/minions/master",
      "mkdir /srv/salt",

      "systemctl start salt-master",
      "systemctl start salt-minion",
      "systemctl enable salt-master",
      "systemctl enable salt-minion",
      "sleep 10",
      "salt '*' test.ping",
    ]
  }*/

  # delete minion key on master when destroying
  /*provisioner "remote-exec" {
    when = destroy

    inline = [
      "salt-key -y -d 'master'",
    ]

    connection {
      private_key = self.triggers.private_key
      host        = self.triggers.saltmasterip
      user        = "root"
    }
  }*/
}