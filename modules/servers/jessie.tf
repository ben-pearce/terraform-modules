resource "proxmox_virtual_environment_vm" "jessie_data" {
  name                = "jessie-data"
  reboot_after_update = false
  tags                = ["data-only"]

  node_name = "pve"
  vm_id     = 5100

  started  = false
  on_boot  = false
  template = true

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    file_format  = "raw"
    size         = 64
  }

  lifecycle {
    ignore_changes = [startup, cpu, memory]
  }
}

resource "proxmox_virtual_environment_vm" "jessie" {
  name                = "jessie"
  reboot_after_update = true
  tags                = ["internal", "noble", "ubuntu"]

  node_name = "pve"
  vm_id     = 100
  bios      = "ovmf"

  initialization {
    vendor_data_file_id = proxmox_virtual_environment_file.cloud_config_vdb.id
    interface           = "scsi0"

    user_account {
      keys     = [trimspace(file(var.public_key_file))]
      password = random_password.ubuntu_vm_password.result
      username = var.default_user
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_noble_template.id
  }

  startup {
    order      = "2"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores        = 8
    type         = "host"
    architecture = "x86_64"
  }

  memory {
    dedicated = 24576
    floating  = 24576
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 64
  }

  dynamic "disk" {
    for_each = { for idx, val in proxmox_virtual_environment_vm.jessie_data.disk : idx => val }
    iterator = data_disk
    content {
      datastore_id      = data_disk.value["datastore_id"]
      path_in_datastore = data_disk.value["path_in_datastore"]
      file_format       = data_disk.value["file_format"]
      size              = data_disk.value["size"]
      interface         = "virtio${data_disk.key + 1}"
      iothread          = true
      discard           = "on"
    }
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 10
    mac_address = "02:00:00:00:01:00"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.default_user} --private-key ${var.private_key_file} ansible/jessie.yml"
  }

  depends_on = [
    proxmox_virtual_environment_vm.jessie_data,
    proxmox_virtual_environment_vm.barbie
  ]
}
