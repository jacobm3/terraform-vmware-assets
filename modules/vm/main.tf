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

  provisioner "remote-exec" {
    inline = [
      "echo ${var.ubuntu_password} | sudo -S sudo apt-get update",
      "echo ${var.ubuntu_password} | sudo -S sudo apt-get install -y cowsay",
      "cowsay Moo!",
    ]
  }

}

