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
### Volumes
##############################

variable "server_name" {
  type      = string
  sensitive = false
}

variable "volume_count" {
  type      = number
  sensitive = false
}

variable "volume_name" {
  type      = string
  sensitive = false
}

variable "volume_labels" {
  type      = map(string)
  sensitive = false
}

variable "volume_size" {
  type      = number
  sensitive = false

  validation {
    condition     = var.volume_size >= 10
    error_message = "Volume minium size is 10 GB."
  }
}

variable "volume_serverid" {
  type      = list(string)
  sensitive = false
}

variable "volume_fs" {
  type      = string
  sensitive = false

  validation {
    condition     = var.volume_fs == "ext4" || var.volume_fs == "xfs"
    error_message = "Filesystem needs to be ext4 or xfs."
  }
}