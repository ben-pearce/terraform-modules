resource "proxmox_virtual_environment_vm" "rc_data" {
  name                = "rc-data"
  reboot_after_update = false
  tags                = ["data-only"]

  node_name = "pve"
  vm_id     = 5201

  started  = false
  on_boot  = false
  template = true

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    file_format  = "raw"
    size         = 16
  }

  lifecycle {
    ignore_changes = [startup, cpu, memory]
  }
}

resource "proxmox_virtual_environment_vm" "rc" {
  name                = "rc"
  reboot_after_update = true
  tags                = ["external", "noble", "ubuntu"]

  node_name = "pve"
  vm_id     = 201
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

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  startup {
    order      = "1"
    up_delay   = "60"
    down_delay = "60"
  }

  efi_disk {
    datastore_id      = "local-lvm"
    type              = "4m"
    pre_enrolled_keys = true
  }

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_noble_template.id
  }

  cpu {
    cores        = 2
    type         = "host"
    architecture = "x86_64"
  }

  memory {
    dedicated = 8192
    floating  = 8192
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 8
  }

  dynamic "disk" {
    for_each = { for idx, val in proxmox_virtual_environment_vm.rc_data.disk : idx => val }
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
    vlan_id     = 200
    mac_address = "02:00:00:00:02:01"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.default_user} --private-key ${var.private_key_file} ansible/rc.yml"
  }

  lifecycle {
    ignore_changes = [clone]
  }

  depends_on = [
    proxmox_virtual_environment_vm.rc_data,
    proxmox_virtual_environment_vm.barbie
  ]
}
