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
    saltmasterid   = "${hcloud_server.saltbastion.id}"
    saltmasterip   = hcloud_server.saltbastion.ipv4_address
    private_key    = var.terraform_private_ssh_key

    # Load files and watch for changes on disk
    file_cloudflare_ini = templatefile("${path.root}/files/cloudflare.ini", {
      cloudflare_email   = var.cloudflare_email
      cloudflare_api_key = var.cloudflare_api_key
    })

    file_install_saltmaster = "${path.root}/scripts/install-salt-master.sh"
  }

  provisioner "file" {
    content = self.triggers.file_cloudflare_ini
    destination = "/root/cloudflare.ini"
  }

  provisioner "file" {
    source      = self.triggers.file_install_saltmaster
    destination = "/tmp/install-salt-master.sh"
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
    saltmasterid   = "${hcloud_server.saltbastion.id}"
    saltmasterip   = hcloud_server.saltbastion.ipv4_address
    server_name    = hcloud_server.saltbastion.name
    private_key    = var.terraform_private_ssh_key
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-salt-master.sh",
      "/tmp/install-salt-master.sh",
      "chmod +x /tmp/setup-git-hook.sh",
      "/tmp/setup-git-hook.sh"
    ]

    connection {
      private_key = self.triggers.private_key
      host        = self.triggers.saltmasterip
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
      host        = self.triggers.saltmasterip
      user        = "root"
    }
  }
}