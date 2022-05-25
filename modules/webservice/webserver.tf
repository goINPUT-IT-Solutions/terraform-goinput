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
### Random names and passwords
##############################


/*


resource "random_pet" "webserver_names" {
  length = 2
  count  = 3
}

##############################
### Webserver
##############################

resource "hcloud_server" "webserver" {
  count       = 3
  name        = "${random_pet.webserver_names.id}.${var.service_name}.${var.domain}"
  image       = "ubuntu-20.04"
  server_type = "cx11"

  ssh_keys = ["${var.terraform_ssh_key_id}"]
  location = "fsn1"

  network {
    network_id = var.network_webservice_id
  }

  firewall_ids = [
    var.firewall_default_id
  ]
}


///////////////////////////////////////////////////////////
// Webserver config
///////////////////////////////////////////////////////////
resource "null_resource" "webserver_config" {

 depends_on = [
     hcloud_server.webserver
]

 count      = hcloud_server.webserver.count

 connection {
   private_key  = file(abspath("${path.root}/keys/terraform_ssh_key"))
    host        = hcloud_server.webserver.ipv4_address
    user        = "root"
 }

 # copy etc/hosts file to web server
 provisioner "file" {
   source      = "salt/srv/salt/common/hosts"
   destination = "/etc/hosts"
 }

 # make the magic happen on web server
 provisioner "remote-exec" {
   inline = [

     "echo ${format("web-%02d", count.index +1)} > /etc/hostname",
     "hostnamectl set-hostname ${format("web-%02d", count.index +1)} --static",
     "hostnamectl set-hostname ${format("web-%02d", count.index +1)} --pretty",
     "hostnamectl set-hostname ${format("web-%02d", count.index +1)} --transient",
     "ip route add default via ${profitbricks_nic.fw-01_dmz_nic.ips.0}",
     "echo 'supersede routers ${profitbricks_nic.fw-01_dmz_nic.ips.0};' >> /etc/dhcp/dhclient.conf",
     "echo nameserver 8.8.8.8 > /etc/resolv.conf",

     "echo -e  'y\n'| ssh-keygen -b 2048 -t rsa -P '' -f /root/.ssh/id_rsa -q",

     "wget -O /tmp/bootstrap-salt.sh https://bootstrap.saltstack.com",
     "sh /tmp/bootstrap-salt.sh -L -X -A ${profitbricks_server.saltmaster.primary_ip}",
     "echo '${format("web-%02d", count.index +1)}' > /etc/salt/minion_id",
     "systemctl restart salt-minion",
     "systemctl enable salt-minion",
   ]
 }
 # Accept minion key on master
 provisioner "remote-exec" {
   inline = [
     "salt-key -y -a ${element(profitbricks_server.web.*.name, count.index)}",
   ]

   connection {
     private_key         = "${file(var.ssh_private_key)}"
     host                = "${profitbricks_server.saltmaster.primary_ip}"
     bastion_host        = "${profitbricks_server.bastion.primary_ip}"
     bastion_user        = "root"
     bastion_private_key = "${file(var.ssh_private_key)}"
     timeout             = "4m"
   }
 }
 # Add or update web server host name to local hosts file
 provisioner "local-exec" {
   command = "grep -q '${element(profitbricks_server.web.*.name, count.index)}' salt/srv/salt/common/hosts && sed -i '' 's/^${element(profitbricks_server.web.*.primary_ip, count.index)}.${element(profitbricks_server.web.*.primary_ip, count.index)} ${element(profitbricks_server.web.*.name, count.index)}/' salt/srv/salt/common/hosts || echo '${element(profitbricks_server.web.*.primary_ip, count.index)} ${element(profitbricks_server.web.*.name, count.index)}' >> salt/srv/salt/common/hosts"
 }
 # delete minion key on master when destroying
 provisioner "remote-exec" {
   when = "destroy"

   inline = [
     "salt-key -y -d '${element(profitbricks_server.web.*.name, count.index)}*'",
   ]

   connection {
     private_key         = "${file(var.ssh_private_key)}"
     host                = "${profitbricks_server.saltmaster.primary_ip}"
     bastion_host        = "${profitbricks_server.bastion.primary_ip}"
     bastion_user        = "root"
     bastion_private_key = "${file(var.ssh_private_key)}"
     timeout             = "4m"
   }
 }

 # delete host from local hosts file when destroying
 provisioner "local-exec" {
   when    = "destroy"
   command = "sed -i '' '/${element(profitbricks_server.web.*.name, count.index)}/d' salt/srv/salt/common/hosts"
 }
}
*/
