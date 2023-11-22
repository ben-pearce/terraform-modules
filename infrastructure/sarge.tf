resource "proxmox_vm_qemu" "sarge" {
  count = 1
  name  = "sarge"
  vmid  = 106
  tags  = "internal;"

  target_node = "pve"

  iso = "local:iso/proxmox-backup-server.iso"

  agent    = 1
  bios     = "ovmf"
  cores    = 2
  sockets  = 1
  cpu      = "host"
  memory   = 2048
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  numa     = false
  qemu_os  = "other"
  onboot   = true

  disk {
    size     = "32G"
    type     = "virtio"
    storage  = "local-lvm"
    iothread = 1
    discard  = "on"
  }

  network {
    model   = "virtio"
    bridge  = "vmbr0"
    tag     = 10
    macaddr = "02:00:00:00:01:06"
  }

  vga {
    memory = 0
    type   = "std"
  }

  lifecycle {
    ignore_changes = [
      network, disk
    ]
  }

}
