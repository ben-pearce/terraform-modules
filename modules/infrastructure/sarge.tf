resource "proxmox_virtual_environment_vm" "sarge" {
  name        = "sarge"
  tags        = ["internal"]

  node_name = "pve"
  vm_id     = 106
  started   = false
  bios      = "ovmf"

  startup {
    order      = "1"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }
  
  cdrom {
    enabled = true
    file_id = proxmox_virtual_environment_file.proxmox_backup_server_iso.id
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 32
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 10
    mac_address = "02:00:00:00:01:06"
  }

}
