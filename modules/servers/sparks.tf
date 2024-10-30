resource "proxmox_virtual_environment_vm" "sparks" {
  name        = "sparks"
  tags        = ["internal", "noble", "ubuntu"]

  node_name = "pve"
  vm_id     = 104
  bios      = "ovmf"

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_noble_template.id
  }

  cpu {
    cores         = 16
    type          = "host"
    architecture  = "x86_64"
  }

  memory {
    dedicated = 32768
    floating  = 32768
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 32
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(file(var.public_key_file))]
      password = random_password.ubuntu_vm_password.result
      username = var.default_user
    }

    vendor_data_file_id = proxmox_virtual_environment_file.cloud_config.id
    interface = "scsi0"
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 10
    mac_address = "02:00:00:00:01:04"
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 10
    mac_address = "02:00:00:01:01:04"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.default_user} --private-key ${var.private_key_file} ansible/sparks.yml"
  }

  depends_on = [ proxmox_virtual_environment_vm.barbie ]
}
