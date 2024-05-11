resource "proxmox_virtual_environment_vm" "woody_data" {
  name      = "woody-data"
  tags      = ["internal", "data-only"]
  
  node_name = "pve"
  vm_id     = 5200

  started   = false
  on_boot   = false
  template  = true
  
  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    file_format  = "raw"
    size         = 64
  }

  lifecycle {
    ignore_changes = [ startup, cpu, memory ]
  }
}

resource "proxmox_virtual_environment_vm" "woody" {
  name        = "woody"
  tags        = ["external", "noble", "ubuntu"]

  node_name = "pve"
  vm_id     = 200
  bios      = "ovmf"

  initialization {
    vendor_data_file_id = proxmox_virtual_environment_file.cloud_config_vdb.id
    interface = "scsi0"
  }

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_noble_template.id
  }

  cpu {
    cores = 6
    type  = "host"
  }

  memory {
    dedicated = 20480
    floating  = 20480
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 32
  }

  dynamic "disk" {
    for_each = { for idx, val in proxmox_virtual_environment_vm.woody_data.disk : idx => val }
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
    vlan_id     = 20
    mac_address = "02:00:00:00:02:00"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.default_user} --private-key ${var.private_key_file} ansible-playbooks/woody.yml"
  }

  depends_on = [ 
    proxmox_virtual_environment_vm.woody_data,
    proxmox_virtual_environment_vm.barbie 
  ]
}
