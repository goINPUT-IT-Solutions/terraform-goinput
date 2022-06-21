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

output "volume_meta" {
  value = [for volume in hcloud_volume.webservice_volume : {
    "id"            = volume.id
    "name"          = volume.name
    "device"        = volume.linux_device
    "fs"            = var.volumes[substr(volume.name, 0, length(volume.name)-2)].fs
    "mountpoint"    = var.volumes[substr(volume.name, 0, length(volume.name)-2)].mount
  }]
}