resource "proxmox_virtual_environment_vm" "sarge" {
  name                = "sarge"
  reboot_after_update = true
  tags                = ["internal"]

  node_name = "pve"
  vm_id     = 106
  started   = false
  on_boot   = true
  bios      = "ovmf"

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  startup {
    order      = "2"
    up_delay   = "60"
    down_delay = "60"
  }

  efi_disk {
    datastore_id      = "local-lvm"
    type              = "4m"
    pre_enrolled_keys = true
  }

  cpu {
    cores        = 2
    type         = "host"
    architecture = "x86_64"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  cdrom {
    file_id = proxmox_virtual_environment_file.proxmox_backup_server_iso.id
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    file_format  = "raw"
    iothread     = true
    discard      = "on"
    size         = 10
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 10
    mac_address = "02:00:00:00:01:06"
  }

  lifecycle {
    ignore_changes = [started]
  }

}
