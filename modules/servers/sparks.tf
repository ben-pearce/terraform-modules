resource "proxmox_virtual_environment_file" "cloud_config_sparks" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = file("${path.module}/snippets/sparks.cloud-config.yaml")
    file_name = "sparks.cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "sparks_data" {
  name      = "sparks-data"
  tags      = ["data-only"]
  
  node_name = "pve"
  vm_id     = 5104

  started   = false
  on_boot   = false
  template  = true
  
  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    file_format  = "raw"
    size         = 16
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio1"
    file_format  = "raw"
    size         = 16
  }

  lifecycle {
    ignore_changes = [ startup, cpu, memory ]
  }
}

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

  dynamic "disk" {
    for_each = { for idx, val in proxmox_virtual_environment_vm.sparks_data.disk : idx => val }
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

    vendor_data_file_id = proxmox_virtual_environment_file.cloud_config_sparks.id
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

  depends_on = [
    proxmox_virtual_environment_vm.sparks_data,
    proxmox_virtual_environment_vm.barbie 
  ]
}
