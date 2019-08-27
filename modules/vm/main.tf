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
  wait_for_guest_net_routable = false
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

    customize {
      linux_options {
        host_name = "terraform-test"
        domain    = "test.internal"
      }

      network_interface {
        ipv4_address = "10.0.0.23"
        ipv4_netmask = 24
      }

      ipv4_gateway = "10.0.0.1"
    }
  }

  tags = ["${var.tags}"]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install cowsay",
      "cowsay Moo!",
    ]

    connection {
      type     = "ssh"
      user     = "${var.ubuntu_user}"
      password = "${var.ubuntu_password}"
    }
  }
}
