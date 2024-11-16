resource "proxmox_virtual_environment_container" "beta" {
  node_name   = "pve"
  vm_id       = 1001
  tags        = ["internal", "noble", "lxc", "ubuntu"]

  initialization {
    hostname = "beta"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  clone {
    node_name     = "pve"
    datastore_id  = "local-lvm"
    vm_id         = proxmox_virtual_environment_container.lxc_ubuntu_noble_template.id
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = 16
  }

  memory {
    dedicated = 12288
  }

  network_interface {
    name        = "eth0"
    vlan_id     = 10
    mac_address = "02:00:00:00:10:01"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu --private-key ${var.private_key_file} ansible/beta.yml"
  }
}