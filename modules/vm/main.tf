variable "dc" {
  default = "PacketDatacenter"
}

data "vsphere_datacenter" "dc" {
  name = "${var.dc}"
}

data "vsphere_virtual_machine" "template" {
  name          = "Ubuntu"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "${var.project}-terraform-vm"
  resource_pool_id = "${var.resource_pool_id}"
  datastore_id     = "${var.datastore_id}"

  num_cpus                    = 2
  memory                      = 1024
  guest_id                    = "ubuntu64Guest"
  wait_for_guest_net_routable = true
  wait_for_guest_net_timeout  = 0

  network_interface {
    network_id = "${var.network_id}"
  }

  disk {
    label = "disk0"
    size  = 20
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }

  tags = ["${var.tags}"]

  provisioner "remote-exec" {
    inline = [
      "echo ${var.ubuntu_password} | sudo -S sudo apt-get update",
      "echo ${var.ubuntu_password} | sudo -S sudo apt-get install cowsay",
      "cowsay Moo!",
    ]

    connection {
      type     = "ssh"
      user     = "${var.ubuntu_user}"
      password = "${var.ubuntu_password}"
    }
  }
}
