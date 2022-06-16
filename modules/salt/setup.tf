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
### Terraform x SaltStack
##############################

/*resource "null_resource" "saltstack_project" {
  depends_on = [
    hcloud_server.saltbastion
  ]

  triggers = {
    serverID    = hcloud_server.saltbastion.id # Force rebuild if server id changes
    serverName  = hcloud_server.saltbastion.name
    serverIP    = hcloud_server.saltbastion.ipv4_address
    privateKey  = var.terraform_private_ssh_key

    file_top_pillar = templatefile("${path.root}/salt/pillar/top.sls", {
      servers = var.salt_servers
      environment = var.environment
      domain = var.domain
    })

    file_terraform_pillar = templatefile("${path.root}/salt/pillar/terraform.sls", {
    })

    file_top_sls = templatefile("${path.root}/salt/states/top.sls", {
      servers = var.salt_servers
      environment = var.environment
      domain = var.domain
    })

    file_mounts_sls = templatefile("${path.root}/salt/states/mounts.sls", {
    })
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -pv /srv/salt/terraform",
      "mkdir -pv /srv/salt/terraform/pillar",
      "mkdir -pv /srv/salt/terraform/states",
    ]
  }

  provisioner "file" {
    content     = self.triggers.file_top_pillar
    destination = "/srv/salt/terraform/pillar/top.sls"
  }

  provisioner "file" {
    content     = self.triggers.file_terraform_pillar
    destination = "/srv/salt/terraform/pillar/terraform.sls"
  }


  provisioner "file" {
    content     = self.triggers.file_top_sls
    destination = "/srv/salt/terraform/states/top.sls"
  }

  provisioner "file" {
    content     = self.triggers.file_mounts_sls
    destination = "/srv/salt/terraform/states/mounts.sls"
  }

  connection {
    private_key = self.triggers.privateKey
    host        = self.triggers.serverIP
    user        = "root"
  }
}*/

##############################
### Salt master config
##############################

resource "null_resource" "saltmaster_files" {
  depends_on = [
    hcloud_server.saltbastion
  ]

  triggers = {
    serverID   = hcloud_server.saltbastion.id # Force rebuild if server id changes
    serverName = hcloud_server.saltbastion.name
    serverIP   = hcloud_server.saltbastion.ipv4_address
    privateKey = var.terraform_private_ssh_key


    # Load files and watch for changes on disk
    file_cloudflare_ini = templatefile("${path.root}/files/cloudflare.ini", {
      cloudflare_email   = var.cloudflare_email
      cloudflare_api_key = var.cloudflare_api_key
    })

    file_install_saltmaster = file("${path.root}/scripts/install-salt-master.sh")

    file_generate_gpg_key = templatefile("${path.root}/scripts/generate_gpg_key.sh", {
      salthost = hcloud_server.saltbastion.name
    })
  }

  provisioner "file" {
    content     = self.triggers.file_cloudflare_ini
    destination = "/root/cloudflare.ini"
  }

  provisioner "file" {
    content     = self.triggers.file_cloudflare_ini
    destination = "/root/.secrets/cloudflare.ini"
  }

  provisioner "file" {
    content     = self.triggers.file_install_saltmaster
    destination = "/tmp/install-salt-master.sh"
  }

  provisioner "file" {
    content     = self.triggers.file_generate_gpg_key
    destination = "/tmp/generate_gpg_key.sh"
  }

  connection {
    private_key = self.triggers.privateKey
    host        = self.triggers.serverIP
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

    # Watch files for change, if change rerun setup
    salt_files = null_resource.saltmaster_files.id
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-salt-master.sh",
      "/tmp/install-salt-master.sh",
      "chmod +x /tmp/generate_gpg_key.sh",
      "/tmp/generate_gpg_key.sh"
    ]

    connection {
      private_key = self.triggers.private_key
      host        = self.triggers.saltmasterip
      user        = "root"
    }
  }
}