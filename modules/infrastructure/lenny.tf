variable "truenas_disk_ids" {
  type     = list(string)
  nullable = false
}

resource "proxmox_virtual_environment_vm" "lenny_data" {
  name      = "lenny-data"
  tags      = ["data-only"]
  
  node_name = "pve"
  vm_id     = 5102

  started   = false
  on_boot   = false
  template  = true
  
  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    file_format  = "raw"
    size         = 256
  }

  lifecycle {
    ignore_changes = [ startup, cpu, memory ]
  }
}

resource "proxmox_virtual_environment_vm" "lenny" {
  name        = "lenny"
  tags        = ["internal"]

  node_name = "pve"
  vm_id     = 103
  started   = false
  on_boot   = true
  bios      = "seabios"

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

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 16384
    floating  = 16384
  }
  
  cdrom {
    enabled = true
    file_id = proxmox_virtual_environment_file.truenas_iso.id
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    iothread     = true
    file_format  = "raw"
    discard      = "on"
    size         = 8
  }

  dynamic "disk" {
    for_each = var.truenas_disk_ids
    content {
      datastore_id        = ""
      interface           = "virtio${disk.key + 1}"
      path_in_datastore   = "/dev/disk/by-id/${disk.value}"
      backup              = false
      file_format         = "raw"
      size                = 9314
    }
  }

  dynamic "disk" {
    for_each = { for idx, val in proxmox_virtual_environment_vm.lenny_data.disk : idx => val }
    iterator = data_disk
    content {
      datastore_id      = data_disk.value["datastore_id"]
      path_in_datastore = data_disk.value["path_in_datastore"]
      file_format       = data_disk.value["file_format"]
      size              = data_disk.value["size"]
      interface         = "virtio${data_disk.key + length(var.truenas_disk_ids) + 1}"
      iothread          = true
      discard           = "on"
      backup            = false
    }
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 10
    mac_address = "02:00:00:00:01:03"
  }

  lifecycle {
    ignore_changes = [ started ]
  }

}
