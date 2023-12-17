variable "truenas_disk_ids" {
  type     = list(string)
  nullable = false
}

resource "proxmox_virtual_environment_vm" "lenny" {
  name        = "lenny"
  tags        = ["internal"]

  node_name = "pve"
  vm_id     = 103
  started   = false

  startup {
    order      = "1"
    up_delay   = "60"
    down_delay = "60"
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
    discard      = "on"
    size         = 32
  }

  dynamic "disk" {
    for_each = var.truenas_disk_ids
    content {
      datastore_id = ""
      interface = "virtio${disk.key + 1}"
      path_in_datastore  = "/dev/disk/by-id/${disk.value}"
      size = 9314
    }
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 10
    mac_address = "02:00:00:00:01:03"
  }

}
