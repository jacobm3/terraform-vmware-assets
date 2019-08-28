variable "dc" {
  default = "PacketDatacenter"
}

data "vsphere_datacenter" "dc" {
  name = var.dc
}

data "vsphere_virtual_machine" "template" {
  name          = "Ubuntu"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "${var.project}-terraform-vm"
  resource_pool_id = var.resource_pool_id
  datastore_id     = var.datastore_id

  num_cpus                    = var.num_cpus
  memory                      = var.memory
  guest_id                    = "ubuntu64Guest"
  wait_for_guest_net_routable = false
  wait_for_guest_net_timeout  = 1

  network_interface {
    network_id = var.network_id
  }

  disk {
    label = "disk0"
    size  = 20
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  connection {
    type     = "ssh"
    host     = self.default_ip_address
    user     = "${var.ubuntu_user}"
    password = "${var.ubuntu_password}"
  }
  #tags = var.tags

  provisioner "file" {
    source      = "modules/vm/files/setup.sh"
    destination = "/home/${var.ubuntu_user}/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 755 /home/${var.ubuntu_user}/setup.sh",
      "echo ${var.ubuntu_password} | sudo -S sudo /home/${var.ubuntu_user}/setup.sh",
      "cowsay Moo!",
    ]
  }

  provisioner "file" {
    source      = "modules/vm/files/index.html"
    destination = "/var/www/html/index.html"
  }

}

