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

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.33.2"
    }
  }
}

##############################
### Volumes
##############################

resource "hcloud_volume" "webservice_volume" {
  count     = var.volume_count
  name      = (count.index >= 9 ? "${var.server_name}${count.index + 1}-${var.volume_name}" : "${var.server_name}0${count.index + 1}-${var.volume_name}")
  size      = var.volume_size
  server_id = var.volume_serverid[count.index]
  automount = false
  format    = var.volume_fs

  labels = var.volume_labels
}

resource "null_resource" "webservice_volume_mount" {
  count = length(hcloud_volume.webservice_volume)
  triggers = {
    volumeID      = hcloud_volume.webservice_volume[count.index].id # Rebuild if id changes
    volumeName    = hcloud_volume.webservice_volume[count.index].name
    volumeMount   = var.volume_mountpoint
    volumeSystemd = var.volume_systemd

    serverIP   = var.volume_serverip[count.index]
    privateKey = var.private_key


    file_mount_template = templatefile("${path.root}/files/mount.template", {
      mountDescription = hcloud_volume.webservice_volume[count.index].name
      mountFilesystem  = var.volume_fs
      mountDevice      = hcloud_volume.webservice_volume[count.index].linux_device
      mountPoint       = var.volume_mountpoint
    })
  }

  provisioner "file" {
    content     = self.triggers.file_mount_template
    destination = "/etc/systemd/system/${self.triggers.volumeSystemd}"

    connection {
      private_key = self.triggers.privateKey
      host        = self.triggers.serverIP
      user        = "root"
    }
  }

  provisioner "remote-exec" {

    inline = [
      "mkdir -pv ${self.triggers.volumeMount}",
      "systemctl start ${self.triggers.volumeSystemd}",
    ]

    connection {
      private_key = self.triggers.privateKey
      host        = self.triggers.serverIP
      user        = "root"
    }
  }
}
